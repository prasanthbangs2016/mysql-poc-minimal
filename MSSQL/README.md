# MSSQL POC (Local, No Docker)

Simple SQL mini‑project designed for a fresh B.Tech graduate (fresher) to demo core database skills using Microsoft SQL Server. Runs locally without Docker.

## Purpose of this demo
- Show you understand relational modeling and how apps store data.
- Practice writing correct, readable, and efficient SQL.
- Learn to analyze performance using execution plans.
- Be able to reset and re-run quickly during learning or interviews.

## Who this is for
- Fresh graduates or new joiners who want a hands-on, minimal setup to practice SQL and explain it confidently in a project review or interview.

## Concepts used in this demo
- Database creation and idempotent scripts:
  - IF DB_ID(...) IS NULL to create database only if missing
  - IF OBJECT_ID(...) IS NULL to create tables only if missing
  - GO batch separators and SET NOCOUNT ON
- Data modeling basics:
  - Tables: customers and orders (a classic 1-to-many relationship)
  - Data types: BIGINT, VARCHAR, DATETIME2
  - Surrogate keys with IDENTITY(1,1)
- Constraints for data correctness:
  - PRIMARY KEY, FOREIGN KEY (with ON UPDATE CASCADE)
  - NOT NULL, UNIQUE (email), CHECK for status values
  - DEFAULT values using SYSUTCDATETIME()
- Indexing for performance:
  - Nonclustered composite index on (customer_id, placed_at) to support common queries
- DML patterns you’ll use in real projects:
  - MERGE for UPSERT (insert-or-update) of customers
  - INSERT INTO ... SELECT with UNION ALL to seed sample rows
- Querying fundamentals:
  - JOIN between customers and orders
  - Filtering with WHERE, sorting with ORDER BY
  - Reading execution plans in SSMS/Azure Data Studio
- Utility patterns:
  - Generating recent timestamps with DATEADD + CHECKSUM(NEWID())
  - Safe resets: TRUNCATE tables or DROP database and re-init

## You need
- Microsoft SQL Server (Developer or Express)
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

## What to demo (as a fresher)
- Walk through the schema: why customers.id and orders.customer_id, and why email is UNIQUE.
- Explain constraints and why they protect data quality.
- Show the composite index and how the query benefits (look at the execution plan).
- Run the example query and describe each clause (SELECT, JOIN, WHERE, ORDER BY).
- Explain how the script can be re-run safely (idempotency and MERGE).

## How this maps to real projects
- Customers↔Orders is the same pattern as Users↔Posts, Accounts↔Transactions, etc.
- Constraints prevent bugs from reaching production data.
- Indexes keep user-facing pages fast at scale.
- Idempotent init scripts are used in CI, local dev, and test environments.

## Practice tasks (optional)
- Add a new status value (e.g., RETURNED) and update the CHECK constraint.
- Create a covering index to speed up the example query (include status, placed_at).
- Write a query to get each customer’s latest order date.
- Add a computed column like order_month = FORMAT(placed_at, 'yyyy-MM').

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
