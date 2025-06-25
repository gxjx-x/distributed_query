"""
Sample data and database initialization for the distributed query system.

This module contains sample data sets and initialization functions
for populating the database with test data.
"""

from .schema import create_tables, check_table_exists, get_table_count

# Sample computer data from the 1970s and 1980s
VINTAGE_COMPUTERS = [
    ('Apple II', 'Apple', 1977, '6502', 48, 'Floppy Disk'),
    ('Commodore 64', 'Commodore', 1982, '6510', 64, 'Cassette/Floppy'),
    ('IBM PC', 'IBM', 1981, '8088', 256, 'Floppy Disk'),
    ('Atari 800', 'Atari', 1979, '6502', 48, 'Cartridge/Cassette'),
    ('TRS-80', 'Tandy', 1977, 'Z80', 16, 'Cassette'),
    ('PET 2001', 'Commodore', 1977, '6502', 32, 'Cassette'),
    ('Apple IIe', 'Apple', 1983, '6502', 128, 'Floppy Disk'),
    ('Sinclair ZX81', 'Sinclair', 1981, 'Z80', 1, 'Cassette'),
    ('BBC Micro', 'Acorn', 1981, '6502', 32, 'Floppy Disk'),
    ('Amstrad CPC', 'Amstrad', 1984, 'Z80', 64, 'Cassette/Floppy')
]

# SQL for inserting computer data
INSERT_COMPUTERS_SQL = """
    INSERT INTO computers (model, manufacturer, year, cpu, ram_kb, storage)
    VALUES (%s, %s, %s, %s, %s, %s)
"""


def insert_sample_computers(conn, computers_data=None):
    """Insert sample computer data into the database"""
    if computers_data is None:
        computers_data = VINTAGE_COMPUTERS
    
    cursor = conn.cursor()
    try:
        cursor.executemany(INSERT_COMPUTERS_SQL, computers_data)
        conn.commit()
        return {
            'status': 'success',
            'message': f'Successfully inserted {len(computers_data)} computers',
            'computers_added': len(computers_data)
        }
    except Exception as e:
        conn.rollback()
        return {
            'status': 'error',
            'message': f'Failed to insert sample data: {str(e)}'
        }


def initialize_database(conn):
    """Initialize the database with schema and sample data"""
    try:
        # First, create the tables (DDL)
        schema_result = create_tables(conn)
        if schema_result['status'] == 'error':
            return schema_result
        
        # Check if data already exists
        existing_count = get_table_count(conn, 'computers')
        
        if existing_count == 0:
            # Insert sample data (DML) - separate transaction
            data_result = insert_sample_computers(conn)
            if data_result['status'] == 'success':
                return {
                    'status': 'success',
                    'message': 'Database initialized with sample data',
                    'computers_added': data_result['computers_added'],
                    'schema_created': True
                }
            else:
                return data_result
        else:
            return {
                'status': 'success',
                'message': 'Database already contains data',
                'existing_computers': existing_count,
                'schema_created': False
            }
            
    except Exception as e:
        return {
            'status': 'error',
            'message': f'Failed to initialize database: {str(e)}'
        }


def reset_database(conn):
    """Reset the database by dropping and recreating tables with fresh data"""
    cursor = conn.cursor()
    try:
        # Drop existing table
        cursor.execute("DROP TABLE IF EXISTS computers CASCADE;")
        conn.commit()
        
        # Recreate and populate
        return initialize_database(conn)
        
    except Exception as e:
        conn.rollback()
        return {
            'status': 'error',
            'message': f'Failed to reset database: {str(e)}'
        }


def add_custom_computer(conn, model, manufacturer, year, cpu, ram_kb, storage):
    """Add a single custom computer to the database"""
    cursor = conn.cursor()
    try:
        cursor.execute(INSERT_COMPUTERS_SQL, (model, manufacturer, year, cpu, ram_kb, storage))
        conn.commit()
        return {
            'status': 'success',
            'message': f'Successfully added {model}',
            'computer_added': {
                'model': model,
                'manufacturer': manufacturer,
                'year': year,
                'cpu': cpu,
                'ram_kb': ram_kb,
                'storage': storage
            }
        }
    except Exception as e:
        conn.rollback()
        return {
            'status': 'error',
            'message': f'Failed to add computer: {str(e)}'
        }
