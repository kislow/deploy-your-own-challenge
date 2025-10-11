-- PostgreSQL Test Data Creation Script
--
-- Usage:
-- docker-compose exec -T postgres psql -U [user] -d company_db < create-test-data.sql
--

-- Drop tables if they exist (for clean reruns)
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS audit_log CASCADE;

-- Create projects table
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    status VARCHAR(20),
    budget DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create employees table
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hired_date DATE DEFAULT CURRENT_DATE
);

-- Create audit log table for testing
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    action VARCHAR(100),
    table_name VARCHAR(50),
    user_name VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert test projects
INSERT INTO projects (name, status, budget) VALUES
    ('Website Redesign', 'Active', 50000),
    ('Mobile App', 'Planning', 120000),
    ('Data Migration', 'Completed', 75000),
    ('Security Audit', 'Active', 30000),
    ('Cloud Infrastructure', 'Planning', 200000),
    ('API Development', 'Active', 85000),
    ('Database Optimization', 'Completed', 45000),
    ('Customer Portal', 'Active', 110000);

-- Insert test employees
INSERT INTO employees (name, email, department, salary) VALUES
    ('John Doe', 'john@company.com', 'Engineering', 95000),
    ('Jane Smith', 'jane@company.com', 'Marketing', 85000),
    ('Bob Wilson', 'bob@company.com', 'Engineering', 105000),
    ('Alice Brown', 'alice@company.com', 'HR', 75000),
    ('Charlie Davis', 'charlie@company.com', 'Sales', 90000),
    ('Emma Johnson', 'emma@company.com', 'Engineering', 98000),
    ('David Lee', 'david@company.com', 'Finance', 92000),
    ('Sarah Williams', 'sarah@company.com', 'Marketing', 78000);

-- Insert audit record
INSERT INTO audit_log (action, table_name, user_name)
VALUES
    ('Test data created', 'all', current_user),
    ('Initial setup', 'projects', current_user),
    ('Initial setup', 'employees', current_user);

-- Display summary
\echo ''
\echo '====================================='
\echo 'Test Data Creation Complete!'
\echo '====================================='
\echo ''

-- Show counts
SELECT 'Projects created:' as info, COUNT(*) as count FROM projects
UNION ALL
SELECT 'Employees created:', COUNT(*) FROM employees
UNION ALL
SELECT 'Audit logs created:', COUNT(*) FROM audit_log;

\echo ''
\echo 'Sample data from projects table:'
SELECT id, name, status, budget FROM projects LIMIT 3;

\echo ''
\echo 'Sample data from employees table:'
SELECT id, name, department, salary FROM employees LIMIT 3;

\echo ''
\echo 'To verify persistence, run:'
\echo '  docker-compose restart'
\echo '  docker-compose exec postgres psql -U [user] -d company_db -c "SELECT COUNT(*) FROM projects;"'
\echo ''
