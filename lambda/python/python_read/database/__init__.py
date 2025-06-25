"""
Database package for the distributed query system.

This package provides modular database functionality including:
- Advanced connection pooling and token caching
- Schema definitions and table creation
- Sample data initialization
- Query operations and data retrieval

Usage:
    from database import get_pooled_connection, return_pooled_connection
    from database import initialize_database, query_all_computers
"""

# Import main functions for easy access
from .pool import (
    get_pooled_connection, 
    return_pooled_connection, 
    get_pool_stats, 
    cleanup_expired_tokens,
    close_all_pools,
    test_connection
)
from .data import initialize_database, reset_database, add_custom_computer
from .queries import (
    query_all_computers,
    query_manufacturers,
    query_years,
    query_cpus,
    query_computers_by_manufacturer,
    query_computers_by_year,
    query_computers_by_cpu,
    search_computers
)
from .schema import create_tables, check_table_exists, get_table_count, list_tables

__all__ = [
    # Connection pooling functions
    'get_pooled_connection',
    'return_pooled_connection',
    'get_pool_stats',
    'cleanup_expired_tokens',
    'close_all_pools',
    'test_connection',
    
    # Data initialization functions
    'initialize_database',
    'reset_database',
    'add_custom_computer',
    
    # Query functions
    'query_all_computers',
    'query_manufacturers',
    'query_years',
    'query_cpus',
    'query_computers_by_manufacturer',
    'query_computers_by_year',
    'query_computers_by_cpu',
    'search_computers',
    
    # Schema functions
    'create_tables',
    'check_table_exists',
    'get_table_count',
    'list_tables'
]
