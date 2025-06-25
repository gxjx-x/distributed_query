"""
Database query functions for the distributed query system.

This module contains all query operations and data retrieval functions
for the computers database.
"""

from .schema import check_table_exists

# Query SQL statements
SELECT_ALL_COMPUTERS_SQL = """
    SELECT id, model, manufacturer, year, cpu, ram_kb, storage 
    FROM computers 
    ORDER BY year, manufacturer;
"""

SELECT_MANUFACTURERS_SQL = """
    SELECT DISTINCT manufacturer 
    FROM computers 
    ORDER BY manufacturer;
"""

SELECT_YEARS_SQL = """
    SELECT DISTINCT year 
    FROM computers 
    ORDER BY year;
"""

SELECT_CPUS_SQL = """
    SELECT DISTINCT cpu 
    FROM computers 
    ORDER BY cpu;
"""

SELECT_BY_MANUFACTURER_SQL = """
    SELECT id, model, manufacturer, year, cpu, ram_kb, storage 
    FROM computers 
    WHERE manufacturer = %s
    ORDER BY year, model;
"""

SELECT_BY_YEAR_SQL = """
    SELECT id, model, manufacturer, year, cpu, ram_kb, storage 
    FROM computers 
    WHERE year = %s
    ORDER BY manufacturer, model;
"""

SELECT_BY_CPU_SQL = """
    SELECT id, model, manufacturer, year, cpu, ram_kb, storage 
    FROM computers 
    WHERE cpu = %s
    ORDER BY year, manufacturer;
"""


def format_computer_record(computer_tuple):
    """Convert a computer database record tuple to a dictionary"""
    return {
        'id': str(computer_tuple[0]),
        'model': computer_tuple[1],
        'manufacturer': computer_tuple[2],
        'year': computer_tuple[3],
        'cpu': computer_tuple[4],
        'ram_kb': computer_tuple[5],
        'storage': computer_tuple[6]
    }


def query_all_computers(conn):
    """Query all computers from the database"""
    cursor = conn.cursor()
    
    try:
        # Check if computers table exists
        table_exists = check_table_exists(conn, 'computers')
        
        if table_exists:
            # If table exists, query it
            cursor.execute(SELECT_ALL_COMPUTERS_SQL)
            computers = cursor.fetchall()
            
            # Convert to list of dictionaries
            computer_list = [format_computer_record(computer) for computer in computers]
            
            return {
                'message': 'Computers data retrieved successfully',
                'status': 'success',
                'count': len(computer_list),
                'data': computer_list
            }
        else:
            # Table doesn't exist yet
            return {
                'message': 'Computers table not found. Use ?query=init to initialize the database.',
                'status': 'success',
                'note': 'Database is connected but no computers table exists yet.'
            }
    except Exception as e:
        return {
            'message': 'Error querying computers table',
            'status': 'error',
            'error': str(e),
            'note': 'Database connected successfully but query failed'
        }


def query_manufacturers(conn):
    """Query unique manufacturers"""
    cursor = conn.cursor()
    try:
        cursor.execute(SELECT_MANUFACTURERS_SQL)
        manufacturers = [row[0] for row in cursor.fetchall()]
        return {
            'status': 'success',
            'manufacturers': manufacturers,
            'count': len(manufacturers)
        }
    except Exception as e:
        return {
            'status': 'error',
            'error': str(e)
        }


def query_years(conn):
    """Query unique years"""
    cursor = conn.cursor()
    try:
        cursor.execute(SELECT_YEARS_SQL)
        years = [row[0] for row in cursor.fetchall()]
        return {
            'status': 'success',
            'years': years,
            'count': len(years)
        }
    except Exception as e:
        return {
            'status': 'error',
            'error': str(e)
        }


def query_cpus(conn):
    """Query unique CPU architectures"""
    cursor = conn.cursor()
    try:
        cursor.execute(SELECT_CPUS_SQL)
        cpus = [row[0] for row in cursor.fetchall()]
        return {
            'status': 'success',
            'cpus': cpus,
            'count': len(cpus)
        }
    except Exception as e:
        return {
            'status': 'error',
            'error': str(e)
        }


def query_computers_by_manufacturer(conn, manufacturer):
    """Query computers by manufacturer"""
    cursor = conn.cursor()
    try:
        cursor.execute(SELECT_BY_MANUFACTURER_SQL, (manufacturer,))
        computers = cursor.fetchall()
        computer_list = [format_computer_record(computer) for computer in computers]
        
        return {
            'status': 'success',
            'manufacturer': manufacturer,
            'count': len(computer_list),
            'data': computer_list
        }
    except Exception as e:
        return {
            'status': 'error',
            'error': str(e)
        }


def query_computers_by_year(conn, year):
    """Query computers by year"""
    cursor = conn.cursor()
    try:
        cursor.execute(SELECT_BY_YEAR_SQL, (year,))
        computers = cursor.fetchall()
        computer_list = [format_computer_record(computer) for computer in computers]
        
        return {
            'status': 'success',
            'year': year,
            'count': len(computer_list),
            'data': computer_list
        }
    except Exception as e:
        return {
            'status': 'error',
            'error': str(e)
        }


def query_computers_by_cpu(conn, cpu):
    """Query computers by CPU architecture"""
    cursor = conn.cursor()
    try:
        cursor.execute(SELECT_BY_CPU_SQL, (cpu,))
        computers = cursor.fetchall()
        computer_list = [format_computer_record(computer) for computer in computers]
        
        return {
            'status': 'success',
            'cpu': cpu,
            'count': len(computer_list),
            'data': computer_list
        }
    except Exception as e:
        return {
            'status': 'error',
            'error': str(e)
        }


def search_computers(conn, search_term):
    """Search computers by model or manufacturer"""
    cursor = conn.cursor()
    try:
        search_sql = """
            SELECT id, model, manufacturer, year, cpu, ram_kb, storage 
            FROM computers 
            WHERE LOWER(model) LIKE LOWER(%s) 
               OR LOWER(manufacturer) LIKE LOWER(%s)
            ORDER BY year, manufacturer, model;
        """
        search_pattern = f"%{search_term}%"
        cursor.execute(search_sql, (search_pattern, search_pattern))
        computers = cursor.fetchall()
        computer_list = [format_computer_record(computer) for computer in computers]
        
        return {
            'status': 'success',
            'search_term': search_term,
            'count': len(computer_list),
            'data': computer_list
        }
    except Exception as e:
        return {
            'status': 'error',
            'error': str(e)
        }
