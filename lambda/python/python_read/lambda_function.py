import json
import os
import boto3
import psycopg2
import psycopg2.extras
import uuid
from datetime import datetime, timedelta
from botocore.auth import SigV4Auth
from botocore.awsrequest import AWSRequest
import urllib.parse

# Configure AWS region
REGION = 'us-west-2'

def get_auth_token(cluster_endpoint):
    """Generate an authentication token for Aurora Postgres DSQL"""
    dsql_client = boto3.client('dsql', region_name=REGION)

    
    # Get the credentials
    session = boto3.Session()
    token = dsql_client.generate_db_connect_admin_auth_token(cluster_endpoint, REGION)
    
    return token

def get_db_connection():
    """Create a database connection using IAM authentication"""
    cluster_endpoint = os.environ.get('CLUSTER_ENDPOINT')
    if not cluster_endpoint:
        raise ValueError("CLUSTER_ENDPOINT environment variable is required")
    
    # Get the auth token
    password_token = get_auth_token(cluster_endpoint)
    
    # Connect to the database
    conn = psycopg2.connect(
        host=cluster_endpoint,
        port=5432,
        database="postgres",
        user="admin",
        password=password_token,
        sslmode='require',
    )
    
    return conn

def query_computers_runtime(conn):
    """Query all computers with related information"""
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    
    query = """
    SELECT 
        c.id,
        c.model,
        m.name as manufacturer,
        c.year,
        c.ram_kb,
        cf.family_name as cpu,
        st.type_name as storage,
        cat.category_name as category
    FROM computers c
    JOIN manufacturers m ON c.manufacturer_id = m.id
    JOIN cpu_families cf ON c.cpu_family_id = cf.id
    JOIN storage_types st ON c.storage_type_id = st.id
    LEFT JOIN computer_categories cat ON c.category_id = cat.id
    ORDER BY c.year, m.name, c.model
    """
    
    cursor.execute(query)
    results = cursor.fetchall()
    
    # Convert UUID objects to strings for JSON serialization
    for row in results:
        if isinstance(row['id'], uuid.UUID):
            row['id'] = str(row['id'])
    
    return results

def query_manufacturer_stats_runtime(conn):
    """Query manufacturer statistics"""
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    
    query = """
    SELECT 
        m.name,
        m.country,
        COUNT(*) as computer_count,
        MIN(c.year) as first_system,
        MAX(c.year) as last_system
    FROM computers c
    JOIN manufacturers m ON c.manufacturer_id = m.id
    GROUP BY m.name, m.country
    ORDER BY computer_count DESC
    """
    
    cursor.execute(query)
    results = cursor.fetchall()
    
    return results

def get_all_cpu_architectures(conn):
    """Get all CPU architectures"""
    cursor = conn.cursor()
    
    query = """
    SELECT family_name FROM cpu_families ORDER BY family_name
    """
    
    cursor.execute(query)
    results = [row[0] for row in cursor.fetchall()]
    
    return results

def find_computers_by_year(conn, target_year):
    """Find computers by year"""
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    
    query = """
    SELECT 
        c.id,
        c.model,
        m.name as manufacturer,
        c.year,
        c.ram_kb,
        cf.family_name as cpu,
        st.type_name as storage,
        cat.category_name as category
    FROM computers c
    JOIN manufacturers m ON c.manufacturer_id = m.id
    JOIN cpu_families cf ON c.cpu_family_id = cf.id
    JOIN storage_types st ON c.storage_type_id = st.id
    LEFT JOIN computer_categories cat ON c.category_id = cat.id
    WHERE c.year = %s
    ORDER BY m.name, c.model
    """
    
    cursor.execute(query, (target_year,))
    results = cursor.fetchall()
    
    # Convert UUID objects to strings for JSON serialization
    for row in results:
        if isinstance(row['id'], uuid.UUID):
            row['id'] = str(row['id'])
    
    return results

def find_computers_by_cpu(conn, target_cpu):
    """Find computers by CPU architecture"""
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    
    query = """
    SELECT 
        c.id,
        c.model,
        m.name as manufacturer,
        c.year,
        c.ram_kb,
        cf.family_name as cpu,
        st.type_name as storage,
        cat.category_name as category
    FROM computers c
    JOIN manufacturers m ON c.manufacturer_id = m.id
    JOIN cpu_families cf ON c.cpu_family_id = cf.id
    JOIN storage_types st ON c.storage_type_id = st.id
    LEFT JOIN computer_categories cat ON c.category_id = cat.id
    WHERE cf.family_name = %s
    ORDER BY m.name, c.model
    """
    
    cursor.execute(query, (target_cpu,))
    results = cursor.fetchall()
    
    # Convert UUID objects to strings for JSON serialization
    for row in results:
        if isinstance(row['id'], uuid.UUID):
            row['id'] = str(row['id'])
    
    return results

def weighted_search(conn, search_term):
    """Search computers with weighted relevance"""
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    
    query = """
    SELECT 
        c.id,
        c.model,
        m.name as manufacturer,
        c.year,
        c.ram_kb,
        cf.family_name as cpu,
        st.type_name as storage,
        cat.category_name as category,
        (
            CASE WHEN LOWER(c.model) LIKE LOWER(%s) THEN 10 ELSE 0 END +
            CASE WHEN LOWER(m.name) LIKE LOWER(%s) THEN 8 ELSE 0 END +
            CASE WHEN LOWER(cf.family_name) LIKE LOWER(%s) THEN 6 ELSE 0 END +
            CASE WHEN LOWER(st.type_name) LIKE LOWER(%s) THEN 3 ELSE 0 END +
            CASE WHEN LOWER(cat.category_name) LIKE LOWER(%s) THEN 2 ELSE 0 END
        )::float8 as search_relevance_score
    FROM computers c
    JOIN manufacturers m ON c.manufacturer_id = m.id
    JOIN cpu_families cf ON c.cpu_family_id = cf.id
    JOIN storage_types st ON c.storage_type_id = st.id
    LEFT JOIN computer_categories cat ON c.category_id = cat.id
    WHERE 
        LOWER(c.model) LIKE LOWER(%s) OR
        LOWER(m.name) LIKE LOWER(%s) OR
        LOWER(cf.family_name) LIKE LOWER(%s) OR
        LOWER(st.type_name) LIKE LOWER(%s) OR
        LOWER(cat.category_name) LIKE LOWER(%s)
    ORDER BY search_relevance_score DESC, c.year DESC
    """
    
    search_pattern = f"%{search_term}%"
    params = [search_pattern] * 10  # We need 10 parameters for the query
    
    cursor.execute(query, params)
    results = cursor.fetchall()
    
    # Convert UUID objects to strings for JSON serialization
    for row in results:
        if isinstance(row['id'], uuid.UUID):
            row['id'] = str(row['id'])
    
    return results

def create_response(body, status_code=200):
    """Create a response with CORS headers"""
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps(body)
    }

def lambda_handler(event, context):
    """Main Lambda handler function"""
    try:
        # Get query parameters
        query_params = event.get('queryStringParameters', {}) or {}
        what = query_params.get('query', 'all_computers')
        
        # Connect to the database
        conn = get_db_connection()
        
        # Process the request based on the query parameter
        if what == 'all_computers':
            result = query_computers_runtime(conn)
        elif what == 'manuf_stats':
            result = query_manufacturer_stats_runtime(conn)
        elif what == 'cpus':
            result = get_all_cpu_architectures(conn)
        elif what == 'year_stats':
            year = int(query_params.get('year', '1988'))
            result = find_computers_by_year(conn, year)
        elif what == 'cpu_computers':
            cpu = query_params.get('cpu', 'Zilog Z80')
            result = find_computers_by_cpu(conn, cpu)
        elif what == 'search':
            term = query_params.get('term', '')
            result = weighted_search(conn, term)
        else:
            result = query_computers_runtime(conn)
        
        # Close the connection
        conn.close()
        
        # Return the response
        return create_response(result)
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return create_response({'error': str(e)}, 500)
