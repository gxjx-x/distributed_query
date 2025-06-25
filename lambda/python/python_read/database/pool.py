"""
Advanced connection pooling and token caching for Aurora DSQL.

This module provides enterprise-grade connection management with:
- Threaded connection pooling
- Automatic token refresh
- Connection health monitoring
- Performance optimization
"""

import os
import boto3
import psycopg2
import psycopg2.pool
import threading
import time
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
from .connection import get_amazon_root_ca_cert

# Global connection pool and cache
_connection_pools: Dict[str, psycopg2.pool.ThreadedConnectionPool] = {}
_token_cache: Dict[str, Dict[str, Any]] = {}
_pool_lock = threading.Lock()
_token_lock = threading.Lock()

# Configuration constants - can be overridden by environment variables
TOKEN_EXPIRATION_SECONDS = int(os.environ.get('TOKEN_EXPIRATION_SECONDS', '900'))  # 15 minutes
TOKEN_REFRESH_SECONDS = int(os.environ.get('TOKEN_REFRESH_SECONDS', '600'))       # 10 minutes
POOL_MIN_CONNECTIONS = int(os.environ.get('POOL_MIN_CONNECTIONS', '1'))
POOL_MAX_CONNECTIONS = int(os.environ.get('POOL_MAX_CONNECTIONS', '5'))


def get_cached_token(cluster_endpoint: str, region: str, cluster_user: str = 'admin') -> Optional[str]:
    """Get a cached authentication token if still valid"""
    cache_key = f"{cluster_endpoint}:{region}:{cluster_user}"
    
    with _token_lock:
        if cache_key in _token_cache:
            token_info = _token_cache[cache_key]
            
            # Check if token is still valid (refresh 5 minutes before expiry)
            if datetime.utcnow() < token_info['expires_at'] - timedelta(seconds=300):
                print(f"Using cached token for {cache_key}")
                return token_info['token']
            else:
                print(f"Token expired for {cache_key}, will refresh")
                del _token_cache[cache_key]
    
    return None


def cache_token(cluster_endpoint: str, region: str, cluster_user: str, token: str) -> None:
    """Cache an authentication token with expiration"""
    cache_key = f"{cluster_endpoint}:{region}:{cluster_user}"
    expires_at = datetime.utcnow() + timedelta(seconds=TOKEN_EXPIRATION_SECONDS)
    
    with _token_lock:
        _token_cache[cache_key] = {
            'token': token,
            'expires_at': expires_at,
            'created_at': datetime.utcnow()
        }
        print(f"Cached token for {cache_key} until {expires_at}")


def generate_fresh_token(cluster_endpoint: str, region: str, cluster_user: str = 'admin') -> str:
    """Generate a fresh authentication token"""
    client = boto3.client("dsql", region_name=region)
    
    if cluster_user == "admin":
        token = client.generate_db_connect_admin_auth_token(cluster_endpoint, region)
    else:
        token = client.generate_db_connect_auth_token(cluster_endpoint, region)
    
    # Cache the token
    cache_token(cluster_endpoint, region, cluster_user, token)
    return token


def get_or_create_token(cluster_endpoint: str, region: str, cluster_user: str = 'admin') -> str:
    """Get a cached token or create a new one"""
    # Try to get cached token first
    token = get_cached_token(cluster_endpoint, region, cluster_user)
    if token:
        return token
    
    # Generate fresh token if no valid cached token
    print(f"Generating fresh token for {cluster_endpoint}")
    return generate_fresh_token(cluster_endpoint, region, cluster_user)


def create_connection_pool(cluster_endpoint: str, region: str, cluster_user: str = 'admin') -> psycopg2.pool.ThreadedConnectionPool:
    """Create a new connection pool with fresh token"""
    token = get_or_create_token(cluster_endpoint, region, cluster_user)
    root_ca_cert_path = get_amazon_root_ca_cert()
    
    conn_params = {
        "dbname": "postgres",
        "user": cluster_user,
        "host": cluster_endpoint,
        "port": "5432",
        "sslmode": "verify-full",
        "sslrootcert": root_ca_cert_path,
        "password": token
    }
    
    # Use the more efficient connection method if it's supported
    if psycopg2.extensions.libpq_version() >= 170000:
        conn_params["sslnegotiation"] = "direct"
    
    # Create the connection pool
    pool = psycopg2.pool.ThreadedConnectionPool(
        POOL_MIN_CONNECTIONS,
        POOL_MAX_CONNECTIONS,
        **conn_params
    )
    
    # Set appropriate schema for all connections in the pool
    schema = "public" if cluster_user == "admin" else "myschema"
    
    # Test the pool by getting a connection and setting schema
    test_conn = pool.getconn()
    try:
        with test_conn.cursor() as cur:
            cur.execute(f"SET search_path = {schema};")
            test_conn.commit()
    finally:
        pool.putconn(test_conn)
    
    print(f"Created connection pool with {POOL_MIN_CONNECTIONS}-{POOL_MAX_CONNECTIONS} connections")
    return pool


def get_connection_pool(cluster_endpoint: str, region: str, cluster_user: str = 'admin') -> psycopg2.pool.ThreadedConnectionPool:
    """Get or create a connection pool"""
    pool_key = f"{cluster_endpoint}:{region}:{cluster_user}"
    
    with _pool_lock:
        if pool_key in _connection_pools:
            pool = _connection_pools[pool_key]
            
            # Test if pool is still healthy
            try:
                test_conn = pool.getconn()
                with test_conn.cursor() as cur:
                    cur.execute("SELECT 1;")
                pool.putconn(test_conn)
                print(f"Using existing connection pool for {pool_key}")
                return pool
            except Exception as e:
                print(f"Connection pool unhealthy for {pool_key}: {e}")
                # Close the unhealthy pool
                try:
                    pool.closeall()
                except:
                    pass
                del _connection_pools[pool_key]
        
        # Create new pool
        print(f"Creating new connection pool for {pool_key}")
        pool = create_connection_pool(cluster_endpoint, region, cluster_user)
        _connection_pools[pool_key] = pool
        return pool


def get_pooled_connection():
    """Get a connection from the pool using environment variables"""
    cluster_user = os.environ.get('CLUSTER_USER', 'admin')
    cluster_endpoint = os.environ.get('CLUSTER_ENDPOINT')
    region = os.environ.get('DSQL_REGION', os.environ.get('AWS_REGION', 'us-east-1'))
    
    if not cluster_endpoint:
        raise ValueError("CLUSTER_ENDPOINT must be provided as environment variable")
    
    pool = get_connection_pool(cluster_endpoint, region, cluster_user)
    return pool.getconn()


def return_pooled_connection(conn):
    """Return a connection to the pool"""
    cluster_user = os.environ.get('CLUSTER_USER', 'admin')
    cluster_endpoint = os.environ.get('CLUSTER_ENDPOINT')
    region = os.environ.get('DSQL_REGION', os.environ.get('AWS_REGION', 'us-east-1'))
    
    pool_key = f"{cluster_endpoint}:{region}:{cluster_user}"
    
    with _pool_lock:
        if pool_key in _connection_pools:
            pool = _connection_pools[pool_key]
            pool.putconn(conn)
        else:
            # Pool doesn't exist, close the connection
            conn.close()


def cleanup_expired_tokens():
    """Clean up expired tokens from cache"""
    with _token_lock:
        current_time = datetime.utcnow()
        expired_keys = []
        
        for key, token_info in _token_cache.items():
            if current_time >= token_info['expires_at']:
                expired_keys.append(key)
        
        for key in expired_keys:
            del _token_cache[key]
            print(f"Cleaned up expired token for {key}")


def get_pool_stats() -> Dict[str, Any]:
    """Get connection pool statistics"""
    stats = {
        'pools': {},
        'tokens': {},
        'configuration': {
            'min_connections': POOL_MIN_CONNECTIONS,
            'max_connections': POOL_MAX_CONNECTIONS,
            'token_expiration_seconds': TOKEN_EXPIRATION_SECONDS,
            'token_refresh_seconds': TOKEN_REFRESH_SECONDS
        }
    }
    
    with _pool_lock:
        for pool_key, pool in _connection_pools.items():
            try:
                stats['pools'][pool_key] = {
                    'min_connections': pool.minconn,
                    'max_connections': pool.maxconn,
                    'current_connections': len(pool._pool) + len(pool._used)
                }
            except Exception as e:
                stats['pools'][pool_key] = {'error': str(e)}
    
    with _token_lock:
        current_time = datetime.utcnow()
        for cache_key, token_info in _token_cache.items():
            stats['tokens'][cache_key] = {
                'created_at': token_info['created_at'].isoformat(),
                'expires_at': token_info['expires_at'].isoformat(),
                'is_valid': current_time < token_info['expires_at'],
                'seconds_until_expiry': (token_info['expires_at'] - current_time).total_seconds()
            }
    
    return stats


def test_connection():
    """Test the database connection using a pooled connection"""
    conn = None
    try:
        conn = get_pooled_connection()
        cursor = conn.cursor()
        
        # Test basic connectivity
        cursor.execute("SELECT version();")
        version = cursor.fetchone()
        
        # Test if we can list tables
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name;
        """)
        tables = cursor.fetchall()
        
        return {
            'status': 'success',
            'database_version': version[0] if version else 'Unknown',
            'tables': [table[0] for table in tables],
            'connection_info': {
                'user': os.environ.get('CLUSTER_USER', 'admin'),
                'host': os.environ.get('CLUSTER_ENDPOINT'),
                'database': 'postgres'
            }
        }
        
    finally:
        if conn is not None:
            return_pooled_connection(conn)


def close_all_pools():
    """Close all connection pools (for cleanup)"""
    with _pool_lock:
        for pool_key, pool in _connection_pools.items():
            try:
                pool.closeall()
                print(f"Closed connection pool for {pool_key}")
            except Exception as e:
                print(f"Error closing pool {pool_key}: {e}")
        _connection_pools.clear()
    
    with _token_lock:
        _token_cache.clear()
        print("Cleared token cache")
