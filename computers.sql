-- =====================================================
-- COMPLETE RELATIONAL DATABASE SCHEMA FOR AMAZON DSQL
-- (Without foreign key constraints - not supported in DSQL)
-- =====================================================

-- 1. MANUFACTURERS TABLE
CREATE TABLE manufacturers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL UNIQUE,
    founded_year INTEGER,
    country VARCHAR(50),
    still_active BOOLEAN DEFAULT FALSE,
    headquarters VARCHAR(100)
);

-- 2. CPU FAMILIES TABLE
CREATE TABLE cpu_families (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_name VARCHAR(50) NOT NULL UNIQUE,
    manufacturer VARCHAR(50) NOT NULL,
    architecture VARCHAR(20),
    instruction_set VARCHAR(50)
);

-- 3. STORAGE TYPES TABLE
CREATE TABLE storage_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type_name VARCHAR(30) NOT NULL UNIQUE,
    capacity_range VARCHAR(50),
    access_speed VARCHAR(20),
    removable BOOLEAN DEFAULT TRUE
);

-- 4. COMPUTER CATEGORIES TABLE
CREATE TABLE computer_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_name VARCHAR(30) NOT NULL UNIQUE,
    description TEXT,
    typical_use_case VARCHAR(100)
);

-- 5. MAIN COMPUTERS TABLE (without foreign key constraints)
CREATE TABLE computers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model VARCHAR(50) NOT NULL,
    manufacturer_id UUID NOT NULL,
    year INTEGER NOT NULL,
    ram_kb INTEGER NOT NULL,
    cpu_family_id UUID NOT NULL,
    storage_type_id UUID NOT NULL,
    category_id UUID,
    original_price_usd DECIMAL(10,2),
    units_sold INTEGER,
    discontinued_year INTEGER,
    notable_features TEXT
);

-- 6. OPERATING SYSTEMS TABLE
CREATE TABLE operating_systems (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    os_name VARCHAR(50) NOT NULL,
    version VARCHAR(20),
    release_year INTEGER,
    developer VARCHAR(50),
    type VARCHAR(20)
);

-- 7. COMPUTER-OS COMPATIBILITY (without foreign key constraints)
CREATE TABLE computer_os_compatibility (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    computer_id UUID NOT NULL,
    os_id UUID NOT NULL,
    native BOOLEAN DEFAULT FALSE,
    requires_addon BOOLEAN DEFAULT FALSE,
    UNIQUE(computer_id, os_id)
);

-- 8. SOFTWARE CATEGORIES TABLE
CREATE TABLE software_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_name VARCHAR(30) NOT NULL UNIQUE
);

-- 9. SOFTWARE TABLE (without foreign key constraints)
CREATE TABLE software (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    software_name VARCHAR(100) NOT NULL,
    developer VARCHAR(50),
    release_year INTEGER,
    category_id UUID,
    price_usd DECIMAL(8,2)
);

-- 10. COMPUTER-SOFTWARE COMPATIBILITY (without foreign key constraints)
CREATE TABLE computer_software_compatibility (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    computer_id UUID NOT NULL,
    software_id UUID NOT NULL,
    min_ram_kb INTEGER,
    requires_disk BOOLEAN DEFAULT FALSE,
    performance_rating INTEGER CHECK (performance_rating BETWEEN 1 AND 5),
    UNIQUE(computer_id, software_id)
);

-- 11. REVIEWS TABLE (without foreign key constraints)
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    computer_id UUID NOT NULL,
    reviewer_name VARCHAR(100),
    review_date DATE,
    rating INTEGER CHECK (rating BETWEEN 1 AND 10),
    review_text TEXT,
    review_type VARCHAR(20) DEFAULT 'User'
);

-- 12. TECHNICAL SPECIFICATIONS TABLE (without foreign key constraints)
CREATE TABLE technical_specifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    computer_id UUID NOT NULL,
    clock_speed_mhz DECIMAL(8,2),
    display_resolution VARCHAR(20),
    sound_capabilities VARCHAR(100),
    expansion_slots INTEGER,
    built_in_ports TEXT,
    power_consumption_watts INTEGER,
    weight_kg DECIMAL(5,2),
    dimensions_cm VARCHAR(30)
);

-- 13. PRICE HISTORY TABLE (without foreign key constraints)
CREATE TABLE price_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    computer_id UUID NOT NULL,
    price_date DATE NOT NULL,
    price_usd DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    source VARCHAR(50)
);

-- =====================================================
-- POPULATE LOOKUP TABLES FIRST
-- =====================================================

-- Insert all manufacturers from your original data
INSERT INTO manufacturers (name, founded_year, country, still_active, headquarters) VALUES
('Apple', 1976, 'USA', TRUE, 'Cupertino, CA'),
('Commodore', 1954, 'USA', FALSE, 'West Chester, PA'),
('Tandy', 1919, 'USA', FALSE, 'Fort Worth, TX'),
('Atari', 1972, 'USA', FALSE, 'Sunnyvale, CA'),
('IBM', 1911, 'USA', TRUE, 'Armonk, NY'),
('Texas Instruments', 1930, 'USA', TRUE, 'Dallas, TX'),
('Sinclair', 1973, 'UK', FALSE, 'Cambridge, UK'),
('Amstrad', 1968, 'UK', TRUE, 'Brentwood, UK'),
('Acorn', 1978, 'UK', FALSE, 'Cambridge, UK'),
('MSX', 1983, 'Japan', FALSE, 'Tokyo, Japan'),
('Osborne', 1980, 'USA', FALSE, 'Hayward, CA'),
('Kaypro', 1982, 'USA', FALSE, 'Solana Beach, CA'),
('Compaq', 1982, 'USA', FALSE, 'Houston, TX'),
('Epson', 1942, 'Japan', TRUE, 'Suwa, Japan'),
('NEC', 1899, 'Japan', TRUE, 'Tokyo, Japan'),
('Sharp', 1912, 'Japan', TRUE, 'Osaka, Japan'),
('Fujitsu', 1935, 'Japan', TRUE, 'Tokyo, Japan'),
('Sord', 1970, 'Japan', FALSE, 'Tokyo, Japan'),
('Canon', 1937, 'Japan', TRUE, 'Tokyo, Japan'),
('Hewlett-Packard', 1939, 'USA', TRUE, 'Palo Alto, CA'),
('Wang', 1951, 'USA', FALSE, 'Lowell, MA'),
('Grid', 1979, 'USA', FALSE, 'Fremont, CA'),
('Zenith', 1918, 'USA', FALSE, 'Chicago, IL'),
('Eagle', 1982, 'USA', FALSE, 'Los Gatos, CA'),
('Leading Edge', 1982, 'USA', FALSE, 'Canton, MA'),
('Sanyo', 1947, 'Japan', TRUE, 'Osaka, Japan'),
('Corona', 1982, 'USA', FALSE, 'Thousand Oaks, CA'),
('Televideo', 1975, 'USA', FALSE, 'San Jose, CA'),
('Vector Graphic', 1976, 'USA', FALSE, 'Thousand Oaks, CA'),
('North Star', 1976, 'USA', FALSE, 'Berkeley, CA'),
('IMSAI', 1973, 'USA', FALSE, 'San Leandro, CA'),
('Altair', 1974, 'USA', FALSE, 'Albuquerque, NM'),
('Processor Technology', 1975, 'USA', FALSE, 'Berkeley, CA'),
('PolyMorphic', 1976, 'USA', FALSE, 'Santa Barbara, CA'),
('Southwest Technical', 1964, 'USA', FALSE, 'San Antonio, TX'),
('Cromemco', 1974, 'USA', FALSE, 'Mountain View, CA'),
('Digital Group', 1974, 'USA', FALSE, 'Denver, CO'),
('Exidy', 1973, 'USA', FALSE, 'Sunnyvale, CA'),
('Ohio Scientific', 1975, 'USA', FALSE, 'Hiram, OH'),
('CompuPro', 1979, 'USA', FALSE, 'Oakland, CA'),
('Morrow', 1980, 'USA', FALSE, 'San Leandro, CA'),
('Telcon', 1982, 'USA', FALSE, 'Fort Lauderdale, FL'),
('Xerox', 1906, 'USA', TRUE, 'Norwalk, CT'),
('Franklin', 1981, 'USA', FALSE, 'Mount Holly, NJ'),
('Lambda', 1982, 'UK', FALSE, 'London, UK'),
('Oric', 1982, 'UK', FALSE, 'Reading, UK'),
('Dragon', 1982, 'UK', FALSE, 'Swansea, Wales'),
('Jupiter', 1982, 'UK', FALSE, 'Cambridge, UK'),
('Mattel', 1945, 'USA', TRUE, 'El Segundo, CA'),
('Coleco', 1932, 'USA', FALSE, 'West Hartford, CT'),
('Enterprise', 1983, 'UK', FALSE, 'London, UK'),
('Sam', 1989, 'UK', FALSE, 'Cambridge, UK'),
('Sun', 1982, 'USA', FALSE, 'Santa Clara, CA'),
('Silicon Graphics', 1981, 'USA', FALSE, 'Mountain View, CA'),
('DEC', 1957, 'USA', FALSE, 'Maynard, MA'),
('HP', 1939, 'USA', TRUE, 'Palo Alto, CA'),
('Next', 1985, 'USA', FALSE, 'Redwood City, CA'),
('Dell', 1984, 'USA', TRUE, 'Round Rock, TX'),
('Gateway', 1985, 'USA', FALSE, 'North Sioux City, SD'),
('Packard Bell', 1986, 'USA', FALSE, 'Sacramento, CA'),
('AST', 1980, 'USA', FALSE, 'Irvine, CA'),
('Intergraph', 1969, 'USA', TRUE, 'Huntsville, AL'),
('Stardent', 1989, 'USA', FALSE, 'Newton, MA'),
('Convex', 1982, 'USA', FALSE, 'Richardson, TX'),
('Cray', 1972, 'USA', TRUE, 'Seattle, WA'),
('Evans & Sutherland', 1968, 'USA', TRUE, 'Salt Lake City, UT'),
('Kubota', 1988, 'Japan', TRUE, 'Osaka, Japan'),
('MIPS', 1984, 'USA', FALSE, 'Sunnyvale, CA'),
('Ardent', 1986, 'USA', FALSE, 'Sunnyvale, CA'),
('Stellar', 1985, 'USA', FALSE, 'Newton, MA'),
('Alliant', 1982, 'USA', FALSE, 'Littleton, MA'),
('Sequent', 1983, 'USA', FALSE, 'Beaverton, OR'),
('Pyramid', 1981, 'USA', FALSE, 'Mountain View, CA'),
('Tandem', 1974, 'USA', FALSE, 'Cupertino, CA'),
('Stratus', 1980, 'USA', TRUE, 'Maynard, MA'),
('Data General', 1968, 'USA', FALSE, 'Westborough, MA'),
('Motorola', 1928, 'USA', TRUE, 'Chicago, IL'),
('NCR', 1884, 'USA', TRUE, 'Dayton, OH'),
('Unisys', 1986, 'USA', TRUE, 'Blue Bell, PA'),
('Prime', 1972, 'USA', FALSE, 'Natick, MA'),
('Concurrent', 1985, 'USA', FALSE, 'Tinton Falls, NJ');

-- Insert all CPU families from your original data
INSERT INTO cpu_families (family_name, manufacturer, architecture, instruction_set) VALUES
('MOS 6502', 'MOS Technology', '8-bit', 'CISC'),
('MOS 65C02', 'MOS Technology', '8-bit', 'CISC'),
('MOS 6502A', 'MOS Technology', '8-bit', 'CISC'),
('MOS 6510', 'MOS Technology', '8-bit', 'CISC'),
('MOS 8502', 'MOS Technology', '8-bit', 'CISC'),
('MOS 7501', 'MOS Technology', '8-bit', 'CISC'),
('MOS 6502C', 'MOS Technology', '8-bit', 'CISC'),
('Motorola 68000', 'Motorola', '16/32-bit', 'CISC'),
('Motorola 68020', 'Motorola', '32-bit', 'CISC'),
('Motorola 68030', 'Motorola', '32-bit', 'CISC'),
('Motorola 68040', 'Motorola', '32-bit', 'CISC'),
('Motorola 6809', 'Motorola', '8-bit', 'CISC'),
('Motorola 6800', 'Motorola', '8-bit', 'CISC'),
('Motorola 88000', 'Motorola', '32-bit', 'RISC'),
('Zilog Z80', 'Zilog', '8-bit', 'CISC'),
('Intel 8088', 'Intel', '16-bit', 'CISC'),
('Intel 80286', 'Intel', '16-bit', 'CISC'),
('Intel 8080', 'Intel', '8-bit', 'CISC'),
('Intel 8085', 'Intel', '8-bit', 'CISC'),
('Intel 8086', 'Intel', '16-bit', 'CISC'),
('Intel 80386', 'Intel', '32-bit', 'CISC'),
('Intel 80386SX', 'Intel', '32-bit', 'CISC'),
('Intel 80386DX', 'Intel', '32-bit', 'CISC'),
('Intel 80486', 'Intel', '32-bit', 'CISC'),
('Intel 80486DX', 'Intel', '32-bit', 'CISC'),
('Intel 80486DX2', 'Intel', '32-bit', 'CISC'),
('Intel Pentium', 'Intel', '32-bit', 'CISC'),
('Intel Pentium Pro', 'Intel', '32-bit', 'CISC'),
('TMS9900', 'Texas Instruments', '16-bit', 'CISC'),
('NSC 800', 'National Semiconductor', '8-bit', 'CISC'),
('Capricorn', 'Hewlett-Packard', '16-bit', 'CISC'),
('SPARC', 'Sun Microsystems', '32-bit', 'RISC'),
('SuperSPARC', 'Sun Microsystems', '32-bit', 'RISC'),
('MicroSPARC II', 'Sun Microsystems', '32-bit', 'RISC'),
('UltraSPARC', 'Sun Microsystems', '64-bit', 'RISC'),
('MIPS R2000', 'MIPS Technologies', '32-bit', 'RISC'),
('MIPS R3000', 'MIPS Technologies', '32-bit', 'RISC'),
('MIPS R4000', 'MIPS Technologies', '32-bit', 'RISC'),
('MIPS R5000', 'MIPS Technologies', '32-bit', 'RISC'),
('MIPS R6000', 'MIPS Technologies', '32-bit', 'RISC'),
('MIPS R10000', 'MIPS Technologies', '32-bit', 'RISC'),
('Alpha 21064', 'Digital Equipment Corp', '64-bit', 'RISC'),
('POWER', 'IBM', '32-bit', 'RISC'),
('PowerPC 601', 'IBM/Motorola', '32-bit', 'RISC'),
('PowerPC 604', 'IBM/Motorola', '32-bit', 'RISC'),
('PowerPC AS', 'IBM', '32-bit', 'RISC'),
('IMPI', 'IBM', '32-bit', 'CISC'),
('PA-RISC', 'Hewlett-Packard', '32-bit', 'RISC'),
('i860', 'Intel', '32-bit', 'RISC'),
('Clipper C100', 'Intergraph', '32-bit', 'RISC'),
('Clipper C300', 'Intergraph', '32-bit', 'RISC'),
('Convex Vector', 'Convex', '64-bit', 'Vector'),
('Cray Vector', 'Cray Research', '64-bit', 'Vector');

-- Insert all storage types from your original data
INSERT INTO storage_types (type_name, capacity_range, access_speed, removable) VALUES
('Cassette Tape', '1KB - 100KB', 'Very Slow', TRUE),
('Floppy Disk', '100KB - 1.4MB', 'Medium', TRUE),
('Hard Disk', '5MB - 1GB+', 'Fast', FALSE),
('Cartridge', '1KB - 1MB', 'Fast', TRUE),
('Paper Tape', '1KB - 10KB', 'Very Slow', TRUE),
('Tape Drive', '100KB - 1MB', 'Slow', TRUE),
('Bubble Memory', '92KB - 1MB', 'Medium', FALSE),
('Magneto-optical', '128MB - 1GB', 'Medium', TRUE),
('Tape Cartridge', '100KB - 10MB', 'Slow', TRUE),
('ROM Pack', '1KB - 64KB', 'Fast', TRUE);

-- Insert computer categories
INSERT INTO computer_categories (category_name, description, typical_use_case) VALUES
('Home Computer', 'Affordable computers for personal use', 'Gaming, Learning, Basic Productivity'),
('Business Computer', 'Professional desktop systems', 'Office Work, Accounting, Word Processing'),
('Workstation', 'High-performance professional systems', 'CAD, Scientific Computing, Graphics'),
('Server', 'Multi-user enterprise systems', 'Database, File Serving, Network Services'),
('Portable', 'Early laptop and portable systems', 'Mobile Computing, Presentations'),
('Hobbyist Kit', 'Build-it-yourself computer systems', 'Learning, Experimentation, Development');

-- Insert operating systems and software categories first
INSERT INTO operating_systems (os_name, version, release_year, developer, type) VALUES
('Apple DOS', '3.3', 1980, 'Apple', 'Proprietary'),
('CP/M', '2.2', 1979, 'Digital Research', 'Commercial'),
('MS-DOS', '1.0', 1981, 'Microsoft', 'Commercial'),
('MS-DOS', '3.0', 1984, 'Microsoft', 'Commercial'),
('Unix System V', '3.0', 1984, 'AT&T', 'Unix'),
('SunOS', '4.0', 1988, 'Sun Microsystems', 'Unix'),
('IRIX', '3.0', 1988, 'Silicon Graphics', 'Unix'),
('VMS', '4.0', 1984, 'Digital Equipment Corp', 'Proprietary'),
('Mac System', '1.0', 1984, 'Apple', 'Proprietary'),
('AmigaOS', '1.0', 1985, 'Commodore', 'Proprietary');

INSERT INTO software_categories (category_name) VALUES
('Games'),
('Productivity'),
('Development'),
('Graphics'),
('Database'),
('Education'),
('Utilities'),
('Business');

-- =====================================================
-- INSERT ALL 180+ COMPUTERS WITH PROPER UUID LOOKUPS
-- =====================================================

INSERT INTO computers (model, manufacturer_id, year, ram_kb, cpu_family_id, storage_type_id, category_id) VALUES
-- Apple computers
('Apple II', (SELECT id FROM manufacturers WHERE name = 'Apple'), 1977, 4, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Apple II Plus', (SELECT id FROM manufacturers WHERE name = 'Apple'), 1979, 16, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Apple IIe', (SELECT id FROM manufacturers WHERE name = 'Apple'), 1983, 64, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Apple IIc', (SELECT id FROM manufacturers WHERE name = 'Apple'), 1984, 128, (SELECT id FROM cpu_families WHERE family_name = 'MOS 65C02'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Apple III', (SELECT id FROM manufacturers WHERE name = 'Apple'), 1980, 128, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502A'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('Lisa', (SELECT id FROM manufacturers WHERE name = 'Apple'), 1983, 1024, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 68000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Macintosh', (SELECT id FROM manufacturers WHERE name = 'Apple'), 1984, 128, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 68000'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Macintosh IIx', (SELECT id FROM manufacturers WHERE name = 'Apple'), 1988, 1024, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 68030'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Macintosh IIfx', (SELECT id FROM manufacturers WHERE name = 'Apple'), 1990, 4096, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 68030'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Macintosh Quadra 700', (SELECT id FROM manufacturers WHERE name = 'Apple'), 1991, 4096, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 68040'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Macintosh Quadra 950', (SELECT id FROM manufacturers WHERE name = 'Apple'), 1992, 8192, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 68040'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Power Macintosh 6100', (SELECT id FROM manufacturers WHERE name = 'Apple'), 1994, 8192, (SELECT id FROM cpu_families WHERE family_name = 'PowerPC 601'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Power Macintosh 8100', (SELECT id FROM manufacturers WHERE name = 'Apple'), 1994, 16384, (SELECT id FROM cpu_families WHERE family_name = 'PowerPC 601'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Power Macintosh 9500', (SELECT id FROM manufacturers WHERE name = 'Apple'), 1995, 32768, (SELECT id FROM cpu_families WHERE family_name = 'PowerPC 604'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),

-- Commodore computers
('PET 2001', (SELECT id FROM manufacturers WHERE name = 'Commodore'), 1977, 4, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('PET 4016', (SELECT id FROM manufacturers WHERE name = 'Commodore'), 1979, 16, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('PET 8032', (SELECT id FROM manufacturers WHERE name = 'Commodore'), 1980, 32, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('VIC-20', (SELECT id FROM manufacturers WHERE name = 'Commodore'), 1981, 5, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Commodore 64', (SELECT id FROM manufacturers WHERE name = 'Commodore'), 1982, 64, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6510'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Commodore 128', (SELECT id FROM manufacturers WHERE name = 'Commodore'), 1985, 128, (SELECT id FROM cpu_families WHERE family_name = 'MOS 8502'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Plus/4', (SELECT id FROM manufacturers WHERE name = 'Commodore'), 1984, 64, (SELECT id FROM cpu_families WHERE family_name = 'MOS 7501'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Amiga 1000', (SELECT id FROM manufacturers WHERE name = 'Commodore'), 1985, 256, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 68000'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),

-- Tandy computers
('TRS-80 Model I', (SELECT id FROM manufacturers WHERE name = 'Tandy'), 1977, 4, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('TRS-80 Model II', (SELECT id FROM manufacturers WHERE name = 'Tandy'), 1979, 32, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('TRS-80 Model III', (SELECT id FROM manufacturers WHERE name = 'Tandy'), 1980, 16, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('TRS-80 Model 4', (SELECT id FROM manufacturers WHERE name = 'Tandy'), 1983, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('TRS-80 Color Computer', (SELECT id FROM manufacturers WHERE name = 'Tandy'), 1980, 4, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 6809'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('TRS-80 Color Computer 2', (SELECT id FROM manufacturers WHERE name = 'Tandy'), 1983, 16, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 6809'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('TRS-80 Color Computer 3', (SELECT id FROM manufacturers WHERE name = 'Tandy'), 1986, 128, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 6809'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),

-- Atari computers
('Atari 400', (SELECT id FROM manufacturers WHERE name = 'Atari'), 1979, 8, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Atari 800', (SELECT id FROM manufacturers WHERE name = 'Atari'), 1979, 16, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Atari 1200XL', (SELECT id FROM manufacturers WHERE name = 'Atari'), 1983, 64, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502C'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Atari 600XL', (SELECT id FROM manufacturers WHERE name = 'Atari'), 1983, 16, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502C'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Atari 800XL', (SELECT id FROM manufacturers WHERE name = 'Atari'), 1983, 64, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502C'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Atari 130XE', (SELECT id FROM manufacturers WHERE name = 'Atari'), 1985, 128, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502C'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Atari ST', (SELECT id FROM manufacturers WHERE name = 'Atari'), 1985, 512, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 68000'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),

-- IBM computers
('IBM 5150 PC', (SELECT id FROM manufacturers WHERE name = 'IBM'), 1981, 16, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8088'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('IBM PC/XT', (SELECT id FROM manufacturers WHERE name = 'IBM'), 1983, 128, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8088'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('IBM PC/AT', (SELECT id FROM manufacturers WHERE name = 'IBM'), 1984, 256, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80286'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('IBM PCjr', (SELECT id FROM manufacturers WHERE name = 'IBM'), 1984, 64, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8088'), (SELECT id FROM storage_types WHERE type_name = 'Cartridge'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('RS/6000 Model 320', (SELECT id FROM manufacturers WHERE name = 'IBM'), 1990, 16384, (SELECT id FROM cpu_families WHERE family_name = 'POWER'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('RS/6000 Model 540', (SELECT id FROM manufacturers WHERE name = 'IBM'), 1991, 32768, (SELECT id FROM cpu_families WHERE family_name = 'POWER'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('RS/6000 Model 730', (SELECT id FROM manufacturers WHERE name = 'IBM'), 1992, 65536, (SELECT id FROM cpu_families WHERE family_name = 'POWER'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('RS/6000 Model 970', (SELECT id FROM manufacturers WHERE name = 'IBM'), 1995, 131072, (SELECT id FROM cpu_families WHERE family_name = 'PowerPC 604'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('ThinkPad 700', (SELECT id FROM manufacturers WHERE name = 'IBM'), 1992, 4096, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80386SX'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Portable')),
('ThinkPad 750', (SELECT id FROM manufacturers WHERE name = 'IBM'), 1993, 8192, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80486DX'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Portable')),
('AS/400 Model B10', (SELECT id FROM manufacturers WHERE name = 'IBM'), 1990, 8192, (SELECT id FROM cpu_families WHERE family_name = 'IMPI'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),
('AS/400 Model D02', (SELECT id FROM manufacturers WHERE name = 'IBM'), 1994, 16384, (SELECT id FROM cpu_families WHERE family_name = 'PowerPC AS'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),

-- Texas Instruments
('TI-99/4', (SELECT id FROM manufacturers WHERE name = 'Texas Instruments'), 1979, 16, (SELECT id FROM cpu_families WHERE family_name = 'TMS9900'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('TI-99/4A', (SELECT id FROM manufacturers WHERE name = 'Texas Instruments'), 1981, 16, (SELECT id FROM cpu_families WHERE family_name = 'TMS9900'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),

-- Sinclair computers
('ZX80', (SELECT id FROM manufacturers WHERE name = 'Sinclair'), 1980, 1, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('ZX81', (SELECT id FROM manufacturers WHERE name = 'Sinclair'), 1981, 1, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('ZX Spectrum', (SELECT id FROM manufacturers WHERE name = 'Sinclair'), 1982, 16, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('ZX Spectrum +', (SELECT id FROM manufacturers WHERE name = 'Sinclair'), 1984, 48, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),

-- Amstrad computers
('CPC 464', (SELECT id FROM manufacturers WHERE name = 'Amstrad'), 1984, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('CPC 664', (SELECT id FROM manufacturers WHERE name = 'Amstrad'), 1985, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('CPC 6128', (SELECT id FROM manufacturers WHERE name = 'Amstrad'), 1985, 128, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('PCW 8256', (SELECT id FROM manufacturers WHERE name = 'Amstrad'), 1985, 256, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('PCW 8512', (SELECT id FROM manufacturers WHERE name = 'Amstrad'), 1985, 512, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),

-- Acorn computers
('BBC Micro Model A', (SELECT id FROM manufacturers WHERE name = 'Acorn'), 1981, 16, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('BBC Micro Model B', (SELECT id FROM manufacturers WHERE name = 'Acorn'), 1981, 32, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Electron', (SELECT id FROM manufacturers WHERE name = 'Acorn'), 1983, 32, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),

-- MSX computers
('MSX 1', (SELECT id FROM manufacturers WHERE name = 'MSX'), 1983, 16, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('MSX 2', (SELECT id FROM manufacturers WHERE name = 'MSX'), 1985, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),

-- Business computers
('Osborne 1', (SELECT id FROM manufacturers WHERE name = 'Osborne'), 1981, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Portable')),
('Kaypro II', (SELECT id FROM manufacturers WHERE name = 'Kaypro'), 1982, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Portable')),
('Kaypro 4', (SELECT id FROM manufacturers WHERE name = 'Kaypro'), 1984, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Portable')),
('Kaypro 10', (SELECT id FROM manufacturers WHERE name = 'Kaypro'), 1983, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Portable')),
('Compaq Portable', (SELECT id FROM manufacturers WHERE name = 'Compaq'), 1983, 128, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8088'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Portable')),
('Compaq DeskPro 286', (SELECT id FROM manufacturers WHERE name = 'Compaq'), 1986, 512, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80286'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('DeskPro 386', (SELECT id FROM manufacturers WHERE name = 'Compaq'), 1987, 2048, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80386'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('SystemPro', (SELECT id FROM manufacturers WHERE name = 'Compaq'), 1989, 4096, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80386'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),
('Proliant 1000', (SELECT id FROM manufacturers WHERE name = 'Compaq'), 1993, 16384, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80486'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),
('Proliant 4000', (SELECT id FROM manufacturers WHERE name = 'Compaq'), 1995, 32768, (SELECT id FROM cpu_families WHERE family_name = 'Intel Pentium'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),

-- Japanese computers
('QX-10', (SELECT id FROM manufacturers WHERE name = 'Epson'), 1983, 256, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('PC-8001', (SELECT id FROM manufacturers WHERE name = 'NEC'), 1979, 16, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('PC-8801', (SELECT id FROM manufacturers WHERE name = 'NEC'), 1981, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('PC-9801', (SELECT id FROM manufacturers WHERE name = 'NEC'), 1982, 128, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8086'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('MZ-80K', (SELECT id FROM manufacturers WHERE name = 'Sharp'), 1978, 20, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('MZ-700', (SELECT id FROM manufacturers WHERE name = 'Sharp'), 1982, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('X1', (SELECT id FROM manufacturers WHERE name = 'Sharp'), 1982, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('FM-7', (SELECT id FROM manufacturers WHERE name = 'Fujitsu'), 1982, 64, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 6809'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('M5', (SELECT id FROM manufacturers WHERE name = 'Sord'), 1982, 4, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('X-07', (SELECT id FROM manufacturers WHERE name = 'Canon'), 1983, 2, (SELECT id FROM cpu_families WHERE family_name = 'NSC 800'), (SELECT id FROM storage_types WHERE type_name = 'ROM Pack'), (SELECT id FROM computer_categories WHERE category_name = 'Portable')),

-- HP computers
('HP-85', (SELECT id FROM manufacturers WHERE name = 'Hewlett-Packard'), 1980, 16, (SELECT id FROM cpu_families WHERE family_name = 'Capricorn'), (SELECT id FROM storage_types WHERE type_name = 'Tape Cartridge'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('HP-86', (SELECT id FROM manufacturers WHERE name = 'Hewlett-Packard'), 1982, 64, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8086'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('HP-87', (SELECT id FROM manufacturers WHERE name = 'Hewlett-Packard'), 1982, 128, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8086'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('HP-150', (SELECT id FROM manufacturers WHERE name = 'Hewlett-Packard'), 1983, 256, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8088'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('9000 Model 300', (SELECT id FROM manufacturers WHERE name = 'HP'), 1989, 4096, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 68020'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('9000 Model 400', (SELECT id FROM manufacturers WHERE name = 'HP'), 1990, 8192, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 68030'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('9000 Model 700', (SELECT id FROM manufacturers WHERE name = 'HP'), 1991, 16384, (SELECT id FROM cpu_families WHERE family_name = 'PA-RISC'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('9000 Model 800', (SELECT id FROM manufacturers WHERE name = 'HP'), 1992, 32768, (SELECT id FROM cpu_families WHERE family_name = 'PA-RISC'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Vectra 486', (SELECT id FROM manufacturers WHERE name = 'HP'), 1991, 4096, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80486'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('Apollo 9000 Model 425', (SELECT id FROM manufacturers WHERE name = 'HP'), 1989, 16384, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 68040'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Apollo 9000 Model 735', (SELECT id FROM manufacturers WHERE name = 'HP'), 1992, 32768, (SELECT id FROM cpu_families WHERE family_name = 'PA-RISC'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),

-- Other business computers
('Wang Professional Computer', (SELECT id FROM manufacturers WHERE name = 'Wang'), 1985, 256, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8086'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('Compass 1101', (SELECT id FROM manufacturers WHERE name = 'Grid'), 1982, 340, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8086'), (SELECT id FROM storage_types WHERE type_name = 'Bubble Memory'), (SELECT id FROM computer_categories WHERE category_name = 'Portable')),
('Z-100', (SELECT id FROM manufacturers WHERE name = 'Zenith'), 1982, 64, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8085'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('Z-150', (SELECT id FROM manufacturers WHERE name = 'Zenith'), 1984, 128, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8088'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('Z-386', (SELECT id FROM manufacturers WHERE name = 'Zenith'), 1987, 1024, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80386'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('Z-486', (SELECT id FROM manufacturers WHERE name = 'Zenith'), 1991, 4096, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80486'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('Eagle 1600', (SELECT id FROM manufacturers WHERE name = 'Eagle'), 1983, 128, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8088'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('Model D', (SELECT id FROM manufacturers WHERE name = 'Leading Edge'), 1985, 256, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8088'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('MBC-555', (SELECT id FROM manufacturers WHERE name = 'Sanyo'), 1983, 128, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8088'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('PC-400', (SELECT id FROM manufacturers WHERE name = 'Corona'), 1983, 128, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8088'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('TS-803', (SELECT id FROM manufacturers WHERE name = 'Televideo'), 1982, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),

-- Vector Graphic and other kit computers
('Vector 3', (SELECT id FROM manufacturers WHERE name = 'Vector Graphic'), 1978, 32, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Hobbyist Kit')),
('Vector 4', (SELECT id FROM manufacturers WHERE name = 'Vector Graphic'), 1980, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Hobbyist Kit')),
('Horizon', (SELECT id FROM manufacturers WHERE name = 'North Star'), 1977, 16, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Hobbyist Kit')),
('Advantage', (SELECT id FROM manufacturers WHERE name = 'North Star'), 1982, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),

-- Early hobbyist computers
('IMSAI 8080', (SELECT id FROM manufacturers WHERE name = 'IMSAI'), 1975, 4, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8080'), (SELECT id FROM storage_types WHERE type_name = 'Paper Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Hobbyist Kit')),
('Altair 8800', (SELECT id FROM manufacturers WHERE name = 'Altair'), 1975, 1, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8080'), (SELECT id FROM storage_types WHERE type_name = 'Paper Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Hobbyist Kit')),
('Altair 8800b', (SELECT id FROM manufacturers WHERE name = 'Altair'), 1976, 4, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8080'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Hobbyist Kit')),
('SOL-20', (SELECT id FROM manufacturers WHERE name = 'Processor Technology'), 1976, 8, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8080'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Hobbyist Kit')),
('Poly-88', (SELECT id FROM manufacturers WHERE name = 'PolyMorphic'), 1976, 1, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8080'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Hobbyist Kit')),
('SWTP 6800', (SELECT id FROM manufacturers WHERE name = 'Southwest Technical'), 1975, 1, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 6800'), (SELECT id FROM storage_types WHERE type_name = 'Paper Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Hobbyist Kit')),
('Z-2', (SELECT id FROM manufacturers WHERE name = 'Cromemco'), 1977, 32, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Hobbyist Kit')),
('System Three', (SELECT id FROM manufacturers WHERE name = 'Cromemco'), 1979, 256, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('Z80 System', (SELECT id FROM manufacturers WHERE name = 'Digital Group'), 1978, 16, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Hobbyist Kit')),
('Sorcerer', (SELECT id FROM manufacturers WHERE name = 'Exidy'), 1978, 8, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),

-- Ohio Scientific
('Superboard II', (SELECT id FROM manufacturers WHERE name = 'Ohio Scientific'), 1978, 4, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Hobbyist Kit')),
('C1P', (SELECT id FROM manufacturers WHERE name = 'Ohio Scientific'), 1979, 8, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('C4P', (SELECT id FROM manufacturers WHERE name = 'Ohio Scientific'), 1980, 32, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),

-- More business computers
('System 816', (SELECT id FROM manufacturers WHERE name = 'CompuPro'), 1982, 256, (SELECT id FROM cpu_families WHERE family_name = 'Intel 8086'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('Micro Decision', (SELECT id FROM manufacturers WHERE name = 'Morrow'), 1982, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('Zorba', (SELECT id FROM manufacturers WHERE name = 'Telcon'), 1983, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Portable')),
('820', (SELECT id FROM manufacturers WHERE name = 'Xerox'), 1981, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('820-II', (SELECT id FROM manufacturers WHERE name = 'Xerox'), 1982, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),

-- Franklin and other Apple clones
('ACE 1000', (SELECT id FROM manufacturers WHERE name = 'Franklin'), 1982, 64, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('ACE 1200', (SELECT id FROM manufacturers WHERE name = 'Franklin'), 1983, 128, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),

-- UK computers
('Lambda 8300', (SELECT id FROM manufacturers WHERE name = 'Lambda'), 1983, 2, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Oric-1', (SELECT id FROM manufacturers WHERE name = 'Oric'), 1983, 16, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Atmos', (SELECT id FROM manufacturers WHERE name = 'Oric'), 1984, 48, (SELECT id FROM cpu_families WHERE family_name = 'MOS 6502'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Dragon 32', (SELECT id FROM manufacturers WHERE name = 'Dragon'), 1982, 32, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 6809'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Dragon 64', (SELECT id FROM manufacturers WHERE name = 'Dragon'), 1983, 64, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 6809'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Jupiter Ace', (SELECT id FROM manufacturers WHERE name = 'Jupiter'), 1982, 3, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Enterprise 64', (SELECT id FROM manufacturers WHERE name = 'Enterprise'), 1985, 64, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Enterprise 128', (SELECT id FROM manufacturers WHERE name = 'Enterprise'), 1985, 128, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Sam Coupe', (SELECT id FROM manufacturers WHERE name = 'Sam'), 1989, 256, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Floppy Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),

-- Game system computers
('Aquarius', (SELECT id FROM manufacturers WHERE name = 'Mattel'), 1983, 4, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Cassette Tape'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),
('Adam', (SELECT id FROM manufacturers WHERE name = 'Coleco'), 1983, 80, (SELECT id FROM cpu_families WHERE family_name = 'Zilog Z80'), (SELECT id FROM storage_types WHERE type_name = 'Tape Drive'), (SELECT id FROM computer_categories WHERE category_name = 'Home Computer')),

-- Sun Microsystems (complete list)
('SPARCstation 1', (SELECT id FROM manufacturers WHERE name = 'Sun'), 1989, 8192, (SELECT id FROM cpu_families WHERE family_name = 'SPARC'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('SPARCstation 2', (SELECT id FROM manufacturers WHERE name = 'Sun'), 1990, 16384, (SELECT id FROM cpu_families WHERE family_name = 'SPARC'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('SPARCstation 10', (SELECT id FROM manufacturers WHERE name = 'Sun'), 1992, 32768, (SELECT id FROM cpu_families WHERE family_name = 'SuperSPARC'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('SPARCstation 20', (SELECT id FROM manufacturers WHERE name = 'Sun'), 1994, 65536, (SELECT id FROM cpu_families WHERE family_name = 'SuperSPARC'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('SPARCstation 5', (SELECT id FROM manufacturers WHERE name = 'Sun'), 1994, 32768, (SELECT id FROM cpu_families WHERE family_name = 'MicroSPARC II'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Ultra 1', (SELECT id FROM manufacturers WHERE name = 'Sun'), 1995, 65536, (SELECT id FROM cpu_families WHERE family_name = 'UltraSPARC'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Ultra 2', (SELECT id FROM manufacturers WHERE name = 'Sun'), 1997, 131072, (SELECT id FROM cpu_families WHERE family_name = 'UltraSPARC'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),

-- Silicon Graphics (complete list)
('Personal IRIS', (SELECT id FROM manufacturers WHERE name = 'Silicon Graphics'), 1988, 4096, (SELECT id FROM cpu_families WHERE family_name = 'MIPS R2000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('IRIS 4D/25', (SELECT id FROM manufacturers WHERE name = 'Silicon Graphics'), 1989, 8192, (SELECT id FROM cpu_families WHERE family_name = 'MIPS R3000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('IRIS 4D/35', (SELECT id FROM manufacturers WHERE name = 'Silicon Graphics'), 1991, 16384, (SELECT id FROM cpu_families WHERE family_name = 'MIPS R3000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Indigo', (SELECT id FROM manufacturers WHERE name = 'Silicon Graphics'), 1991, 16384, (SELECT id FROM cpu_families WHERE family_name = 'MIPS R3000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Indigo2', (SELECT id FROM manufacturers WHERE name = 'Silicon Graphics'), 1992, 32768, (SELECT id FROM cpu_families WHERE family_name = 'MIPS R4000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Indy', (SELECT id FROM manufacturers WHERE name = 'Silicon Graphics'), 1993, 16384, (SELECT id FROM cpu_families WHERE family_name = 'MIPS R4000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('O2', (SELECT id FROM manufacturers WHERE name = 'Silicon Graphics'), 1996, 32768, (SELECT id FROM cpu_families WHERE family_name = 'MIPS R5000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Octane', (SELECT id FROM manufacturers WHERE name = 'Silicon Graphics'), 1997, 131072, (SELECT id FROM cpu_families WHERE family_name = 'MIPS R10000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Origin 200', (SELECT id FROM manufacturers WHERE name = 'Silicon Graphics'), 1996, 262144, (SELECT id FROM cpu_families WHERE family_name = 'MIPS R10000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),
('Onyx', (SELECT id FROM manufacturers WHERE name = 'Silicon Graphics'), 1993, 65536, (SELECT id FROM cpu_families WHERE family_name = 'MIPS R4000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),

-- DEC computers
('DECstation 3100', (SELECT id FROM manufacturers WHERE name = 'DEC'), 1989, 8192, (SELECT id FROM cpu_families WHERE family_name = 'MIPS R2000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('DECstation 5000', (SELECT id FROM manufacturers WHERE name = 'DEC'), 1990, 16384, (SELECT id FROM cpu_families WHERE family_name = 'MIPS R3000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('AlphaStation 200', (SELECT id FROM manufacturers WHERE name = 'DEC'), 1994, 16384, (SELECT id FROM cpu_families WHERE family_name = 'Alpha 21064'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('AlphaStation 400', (SELECT id FROM manufacturers WHERE name = 'DEC'), 1995, 32768, (SELECT id FROM cpu_families WHERE family_name = 'Alpha 21064'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('AlphaServer 1000', (SELECT id FROM manufacturers WHERE name = 'DEC'), 1994, 65536, (SELECT id FROM cpu_families WHERE family_name = 'Alpha 21064'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),
('AlphaServer 2000', (SELECT id FROM manufacturers WHERE name = 'DEC'), 1995, 131072, (SELECT id FROM cpu_families WHERE family_name = 'Alpha 21064'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),

-- NeXT computers
('NeXT Computer', (SELECT id FROM manufacturers WHERE name = 'Next'), 1988, 8192, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 68030'), (SELECT id FROM storage_types WHERE type_name = 'Magneto-optical'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('NeXTstation', (SELECT id FROM manufacturers WHERE name = 'Next'), 1990, 8192, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 68040'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('NeXTcube', (SELECT id FROM manufacturers WHERE name = 'Next'), 1990, 16384, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 68040'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),

-- PC manufacturers of the 1990s
('System 200', (SELECT id FROM manufacturers WHERE name = 'Dell'), 1990, 1024, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80386'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('OptiPlex GX1', (SELECT id FROM manufacturers WHERE name = 'Dell'), 1991, 4096, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80486'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('Dimension XPS', (SELECT id FROM manufacturers WHERE name = 'Dell'), 1993, 8192, (SELECT id FROM cpu_families WHERE family_name = 'Intel Pentium'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('PowerEdge 1000', (SELECT id FROM manufacturers WHERE name = 'Dell'), 1996, 32768, (SELECT id FROM cpu_families WHERE family_name = 'Intel Pentium Pro'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),
('2000 386DX', (SELECT id FROM manufacturers WHERE name = 'Gateway'), 1990, 2048, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80386DX'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('2000 486', (SELECT id FROM manufacturers WHERE name = 'Gateway'), 1992, 4096, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80486'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('2000 P5-60', (SELECT id FROM manufacturers WHERE name = 'Gateway'), 1993, 8192, (SELECT id FROM cpu_families WHERE family_name = 'Intel Pentium'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('386SX', (SELECT id FROM manufacturers WHERE name = 'Packard Bell'), 1990, 2048, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80386SX'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('486DX2', (SELECT id FROM manufacturers WHERE name = 'Packard Bell'), 1993, 4096, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80486DX2'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('Premium 386', (SELECT id FROM manufacturers WHERE name = 'AST'), 1989, 2048, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80386'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),
('Bravo 486', (SELECT id FROM manufacturers WHERE name = 'AST'), 1992, 4096, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80486'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer')),

-- High-end workstations and specialized systems
('InterPro 32', (SELECT id FROM manufacturers WHERE name = 'Intergraph'), 1989, 8192, (SELECT id FROM cpu_families WHERE family_name = 'Clipper C100'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('InterPro 125', (SELECT id FROM manufacturers WHERE name = 'Intergraph'), 1991, 16384, (SELECT id FROM cpu_families WHERE family_name = 'Clipper C300'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Vistra 800', (SELECT id FROM manufacturers WHERE name = 'Stardent'), 1989, 16384, (SELECT id FROM cpu_families WHERE family_name = 'i860'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('C1', (SELECT id FROM manufacturers WHERE name = 'Convex'), 1990, 32768, (SELECT id FROM cpu_families WHERE family_name = 'Convex Vector'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),
('Cray Y-MP EL', (SELECT id FROM manufacturers WHERE name = 'Cray'), 1990, 32768, (SELECT id FROM cpu_families WHERE family_name = 'Cray Vector'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),
('ESV', (SELECT id FROM manufacturers WHERE name = 'Evans & Sutherland'), 1991, 16384, (SELECT id FROM cpu_families WHERE family_name = 'i860'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Titan', (SELECT id FROM manufacturers WHERE name = 'Kubota'), 1989, 8192, (SELECT id FROM cpu_families WHERE family_name = 'SPARC'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('M/120', (SELECT id FROM manufacturers WHERE name = 'MIPS'), 1988, 8192, (SELECT id FROM cpu_families WHERE family_name = 'MIPS R2000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('M/2000', (SELECT id FROM manufacturers WHERE name = 'MIPS'), 1990, 32768, (SELECT id FROM cpu_families WHERE family_name = 'MIPS R6000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Titan', (SELECT id FROM manufacturers WHERE name = 'Ardent'), 1988, 16384, (SELECT id FROM cpu_families WHERE family_name = 'i860'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('GS1000', (SELECT id FROM manufacturers WHERE name = 'Stellar'), 1989, 16384, (SELECT id FROM cpu_families WHERE family_name = 'i860'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('FX/8', (SELECT id FROM manufacturers WHERE name = 'Alliant'), 1990, 65536, (SELECT id FROM cpu_families WHERE family_name = 'i860'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),
('Symmetry', (SELECT id FROM manufacturers WHERE name = 'Sequent'), 1991, 32768, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80386'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),
('MIServer', (SELECT id FROM manufacturers WHERE name = 'Pyramid'), 1990, 16384, (SELECT id FROM cpu_families WHERE family_name = 'MIPS R3000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),
('Integrity S2', (SELECT id FROM manufacturers WHERE name = 'Tandem'), 1995, 65536, (SELECT id FROM cpu_families WHERE family_name = 'PA-RISC'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),
('Continuum 400', (SELECT id FROM manufacturers WHERE name = 'Stratus'), 1992, 32768, (SELECT id FROM cpu_families WHERE family_name = 'i860'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),
('AViiON', (SELECT id FROM manufacturers WHERE name = 'Data General'), 1989, 8192, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 88000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('Series 900', (SELECT id FROM manufacturers WHERE name = 'Motorola'), 1990, 16384, (SELECT id FROM cpu_families WHERE family_name = 'Motorola 88000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('System 3000', (SELECT id FROM manufacturers WHERE name = 'NCR'), 1991, 16384, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80486'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),
('U6000', (SELECT id FROM manufacturers WHERE name = 'Unisys'), 1990, 32768, (SELECT id FROM cpu_families WHERE family_name = 'MIPS R3000'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Server')),
('EXL 316', (SELECT id FROM manufacturers WHERE name = 'Prime'), 1989, 8192, (SELECT id FROM cpu_families WHERE family_name = 'i860'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Workstation')),
('3200', (SELECT id FROM manufacturers WHERE name = 'Concurrent'), 1990, 8192, (SELECT id FROM cpu_families WHERE family_name = 'Intel 80386'), (SELECT id FROM storage_types WHERE type_name = 'Hard Disk'), (SELECT id FROM computer_categories WHERE category_name = 'Business Computer'));

-- Insert sample software
INSERT INTO software (software_name, developer, release_year, category_id, price_usd) VALUES
('VisiCalc', 'Software Arts', 1979, (SELECT id FROM software_categories WHERE category_name = 'Productivity'), 100.00),
('Lotus 1-2-3', 'Lotus Development', 1983, (SELECT id FROM software_categories WHERE category_name = 'Productivity'), 495.00),
('WordStar', 'MicroPro', 1979, (SELECT id FROM software_categories WHERE category_name = 'Productivity'), 495.00),
('dBASE II', 'Ashton-Tate', 1981, (SELECT id FROM software_categories WHERE category_name = 'Database'), 295.00),
('Pac-Man', 'Atari', 1982, (SELECT id FROM software_categories WHERE category_name = 'Games'), 39.95),
('MacPaint', 'Apple', 1984, (SELECT id FROM software_categories WHERE category_name = 'Graphics'), 125.00),
('AutoCAD', 'Autodesk', 1982, (SELECT id FROM software_categories WHERE category_name = 'Graphics'), 3000.00);

-- Insert sample reviews
INSERT INTO reviews (computer_id, reviewer_name, review_date, rating, review_text, review_type) VALUES
((SELECT id FROM computers WHERE model = 'Apple II' LIMIT 1), 'Byte Magazine', '1977-06-01', 9, 'Revolutionary personal computer that brings computing to the home user.', 'Professional'),
((SELECT id FROM computers WHERE model = 'Commodore 64' LIMIT 1), 'Computer Gaming World', '1982-12-01', 8, 'Outstanding graphics and sound capabilities make this perfect for games.', 'Professional'),
((SELECT id FROM computers WHERE model = 'IBM 5150 PC' LIMIT 1), 'PC Magazine', '1981-10-01', 7, 'Solid business machine but expensive. Will likely become the standard.', 'Professional'),
((SELECT id FROM computers WHERE model = 'Macintosh' LIMIT 1), 'Creative Computing', '1984-03-01', 9, 'The graphical interface is a game-changer. Mouse control feels natural.', 'Professional');

-- =====================================================
-- INDEXES FOR PERFORMANCE (Using DSQL ASYNC syntax)
-- =====================================================

CREATE INDEX ASYNC idx_computers_manufacturer ON computers(manufacturer_id);
CREATE INDEX ASYNC idx_computers_year ON computers(year);
CREATE INDEX ASYNC idx_computers_cpu ON computers(cpu_family_id);
CREATE INDEX ASYNC idx_computers_category ON computers(category_id);
CREATE INDEX ASYNC idx_computers_ram ON computers(ram_kb);

-- =====================================================
-- DISPLAY SUMMARY STATISTICS
-- =====================================================

SELECT 'Database creation completed!' as status
UNION ALL
SELECT 'Total computers: ' || COUNT(*) FROM computers
UNION ALL
SELECT 'Total manufacturers: ' || COUNT(*) FROM manufacturers
UNION ALL
SELECT 'Total CPU families: ' || COUNT(*) FROM cpu_families;