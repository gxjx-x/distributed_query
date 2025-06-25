import json
import os
from datetime import datetime
from typing import Optional, Dict, Any

# Import database modules
from database import (
    get_pooled_connection,
    return_pooled_connection,
    get_pool_stats,
    cleanup_expired_tokens,
    test_connection,
    initialize_database,
    query_all_computers,
    query_manufacturers,
    query_years,
    query_cpus,
    query_computers_by_manufacturer,
    query_computers_by_year,
    query_computers_by_cpu,
    search_computers,
    add_custom_computer,
    reset_database
)


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
        'body': json.dumps(body, indent=2)
    }


def execute_with_pooled_connection(query_function, *args, **kwargs):
    """Execute a query function using a pooled connection"""
    conn = None
    try:
        conn = get_pooled_connection()
        return query_function(conn, *args, **kwargs)
    finally:
        if conn is not None:
            return_pooled_connection(conn)


def lambda_handler(event, context):
    """Main Lambda handler function with connection pooling"""
    try:
        # Clean up expired tokens periodically
        cleanup_expired_tokens()
        
        # Get query parameters
        query_params = event.get('queryStringParameters', {}) or {}
        what = query_params.get('query', 'test')
        test_type = query_params.get('test', None)
        
        # Handle explicit test requests (use pooled connection for testing)
        if test_type == 'connection' or what == 'test':
            result = test_connection()
            return create_response(result)
        
        # Handle pool statistics request
        if what == 'pool_stats':
            result = get_pool_stats()
            result['status'] = 'success'
            result['message'] = 'Connection pool statistics'
            return create_response(result)
        
        # Route to appropriate query function using pooled connections
        if what == 'all_computers':
            result = execute_with_pooled_connection(query_all_computers)
        elif what == 'init':
            result = execute_with_pooled_connection(initialize_database)
        elif what == 'reset':
            result = execute_with_pooled_connection(reset_database)
        elif what == 'manufacturers':
            result = execute_with_pooled_connection(query_manufacturers)
        elif what == 'years':
            result = execute_with_pooled_connection(query_years)
        elif what == 'cpus':
            result = execute_with_pooled_connection(query_cpus)
        elif what.startswith('manufacturer:'):
            manufacturer = what.split(':', 1)[1]
            result = execute_with_pooled_connection(query_computers_by_manufacturer, manufacturer)
        elif what.startswith('year:'):
            try:
                year = int(what.split(':', 1)[1])
                result = execute_with_pooled_connection(query_computers_by_year, year)
            except ValueError:
                result = {
                    'status': 'error',
                    'error': 'Invalid year format. Use year:YYYY'
                }
        elif what.startswith('cpu:'):
            cpu = what.split(':', 1)[1]
            result = execute_with_pooled_connection(query_computers_by_cpu, cpu)
        elif what.startswith('search:'):
            search_term = what.split(':', 1)[1]
            result = execute_with_pooled_connection(search_computers, search_term)
        elif what.startswith('add:'):
            # Format: add:model,manufacturer,year,cpu,ram_kb,storage
            try:
                parts = what.split(':', 1)[1].split(',')
                if len(parts) == 6:
                    model, manufacturer, year, cpu, ram_kb, storage = parts
                    result = execute_with_pooled_connection(
                        add_custom_computer,
                        model.strip(), manufacturer.strip(), 
                        int(year.strip()), cpu.strip(), 
                        int(ram_kb.strip()), storage.strip()
                    )
                else:
                    result = {
                        'status': 'error',
                        'error': 'Invalid format. Use add:model,manufacturer,year,cpu,ram_kb,storage'
                    }
            except (ValueError, IndexError) as e:
                result = {
                    'status': 'error',
                    'error': f'Invalid add format: {str(e)}'
                }
        elif what == 'health':
            # Health check without full connection test
            pool_stats = get_pool_stats()
            result = {
                'status': 'healthy',
                'timestamp': datetime.utcnow().isoformat(),
                'service': 'distributed-query-python',
                'database': 'connected',
                'version': '2.1.0-pooled',
                'connection_pooling': {
                    'enabled': True,
                    'pools_active': len(pool_stats['pools']),
                    'tokens_cached': len(pool_stats['tokens']),
                    'configuration': pool_stats['configuration']
                }
            }
        else:
            result = {
                'message': f'Query type "{what}" is ready for implementation',
                'available_queries': [
                    'test', 'all_computers', 'init', 'reset',
                    'manufacturers', 'years', 'cpus', 'health', 'pool_stats',
                    'manufacturer:NAME', 'year:YYYY', 'cpu:ARCH',
                    'search:TERM', 'add:model,manufacturer,year,cpu,ram_kb,storage'
                ],
                'status': 'success',
                'query_received': what,
                'version': '2.1.0-pooled',
                'connection_pooling': 'enabled'
            }
        
        return create_response(result)
        
    except Exception as e:
        print(f"Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return create_response({
            'error': str(e),
            'type': type(e).__name__,
            'version': '2.1.0-pooled'
        }, 500)
