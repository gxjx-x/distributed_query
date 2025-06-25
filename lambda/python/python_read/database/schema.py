"""
Database schema definitions for the distributed query system.

This module contains all DDL (Data Definition Language) statements
and schema-related operations.
"""

# Table creation SQL
COMPUTERS_TABLE_DDL = """
    CREATE TABLE IF NOT EXISTS computers (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        model VARCHAR(255) NOT NULL,
        manufacturer VARCHAR(255),
        year INTEGER,
        cpu VARCHAR(255),
        ram_kb INTEGER,
        storage VARCHAR(255)
    );
"""

# Schema validation queries
CHECK_TABLE_EXISTS_SQL = """
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'computers'
    );
"""

LIST_TABLES_SQL = """
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    ORDER BY table_name;
"""

GET_TABLE_COUNT_SQL = "SELECT COUNT(*) FROM computers;"


def create_tables(conn):
    """Create all database tables"""
    cursor = conn.cursor()
    try:
        cursor.execute(COMPUTERS_TABLE_DDL)
        conn.commit()
        return {
            'status': 'success',
            'message': 'Tables created successfully'
        }
    except Exception as e:
        conn.rollback()
        return {
            'status': 'error',
            'message': f'Failed to create tables: {str(e)}'
        }


def check_table_exists(conn, table_name='computers'):
    """Check if a specific table exists"""
    cursor = conn.cursor()
    try:
        cursor.execute(CHECK_TABLE_EXISTS_SQL)
        return cursor.fetchone()[0]
    except Exception as e:
        print(f"Error checking table existence: {e}")
        return False


def get_table_count(conn, table_name='computers'):
    """Get the number of records in a table"""
    cursor = conn.cursor()
    try:
        cursor.execute(f"SELECT COUNT(*) FROM {table_name};")
        return cursor.fetchone()[0]
    except Exception as e:
        print(f"Error getting table count: {e}")
        return 0


def list_tables(conn):
    """List all tables in the public schema"""
    cursor = conn.cursor()
    try:
        cursor.execute(LIST_TABLES_SQL)
        return [table[0] for table in cursor.fetchall()]
    except Exception as e:
        print(f"Error listing tables: {e}")
        return []
