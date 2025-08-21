# MSSQL POC (Local, No Docker)

Simple POC to run on your own laptop using Microsoft SQL Server. No Docker.

## Goal
- Learn basic SQL: primary key, foreign key, index, joins, execution plan.
- Use small demo tables: customers and orders.
- Run in SSMS or Azure Data Studio.
- Easy to reset and try again.

## You need
- Microsoft SQL Server (Developer or Express).
- One tool:
  - SSMS (SQL Server Management Studio), or
  - Azure Data Studio

## Setup (5 minutes)
1) Open SSMS or Azure Data Studio and connect to your local SQL Server.
2) Open this file: MSSQL/sql/01_init.sql
3) Run the full script. It will:
   - create database pocdb (if not exists)
   - create tables
   - insert sample data
   - create index

## Check data
Run in database pocdb:

```sql
SELECT COUNT(*) FROM dbo.customers;
SELECT COUNT(*) FROM dbo.orders;
```

Example: get Alice’s recent orders
```sql
SELECT o.id, o.status, o.placed_at
FROM dbo.orders o
JOIN dbo.customers c ON c.id = o.customer_id
WHERE c.email = 'alice@example.com'
ORDER BY o.placed_at DESC;
```

## What to show in demo
- Tables: dbo.customers, dbo.orders
- Primary key and foreign key
- Composite index on (customer_id, placed_at)
- Run query and see Execution Plan (SSMS: Include Actual Execution Plan)

## Reset (fresh start)
Option 1: Drop and recreate database
```sql
USE master;
DROP DATABASE pocdb; -- close any connections first
```
Then run MSSQL/sql/01_init.sql again.

Option 2: Only clear tables
```sql
TRUNCATE TABLE dbo.orders;
TRUNCATE TABLE dbo.customers;
```
Then run only the INSERT parts.

## Troubleshooting
- Cannot connect?
  - Start SQL Server service.
  - Try server name: (local) or . or localhost
- Login issue?
  - Use Windows Authentication or correct SQL user.
- “Database in use” error?
  - Close other query windows using pocdb, switch to master, and try again.