# MSSQL POC (Local, No Docker)

This is a simple Proof of Concept to run on your own laptop using Microsoft SQL Server (no Docker).

## Objective

- Learn and show basic SQL concepts: primary key, foreign key, index, joins, Execution Plan.
- Work with a small demo schema: customers and orders.
- Run everything locally in SSMS or Azure Data Studio.
- Reset and try again easily.

## What you need

- Microsoft SQL Server installed on your laptop (Developer or Express is fine).
- One SQL client:
  - SQL Server Management Studio (SSMS), or
  - Azure Data Studio

## Setup (5 minutes)

1) Open SSMS (or Azure Data Studio) and connect to your local SQL Server.
2) Open the file sql/01_init.sql from this repo (MSSQL/sql/01_init.sql).
3) Run the whole script (it will:
   - create database pocdb if not present,
   - create tables,
   - add sample data,
   - create an index).

## Verify

Run these in pocdb:

- SELECT COUNT(*) FROM dbo.customers;
- SELECT COUNT(*) FROM dbo.orders;

Example query (get Alice’s recent orders):

SELECT o.id, o.status, o.placed_at
FROM dbo.orders o
JOIN dbo.customers c ON c.id = o.customer_id
WHERE c.email = 'alice@example.com'
ORDER BY o.placed_at DESC;

## What to demo

- Show tables: dbo.customers, dbo.orders
- Explain primary key and foreign key relation
- Show composite index on (customer_id, placed_at)
- Run the example query and view the execution plan (SSMS: Include Actual Execution Plan)

## Reset data (fresh start)

Option 1: Drop and recreate database (simple)
- In SSMS:
  - USE master;
  - DROP DATABASE pocdb;  (make sure no active connections)
- Run MSSQL/sql/01_init.sql again.

Option 2: Just clear tables
- TRUNCATE TABLE dbo.orders;
- TRUNCATE TABLE dbo.customers;
- Re-run only the insert parts from the script.

## Troubleshooting

- Cannot connect to SQL Server?
  - Ensure SQL Server service is running.
  - Try server name: (local) or . or localhost
- Login issue?
  - Use Windows Authentication or correct SQL login.
- Script fails on “database in use”?  
  - Close other query windows using pocdb, switch to master, then try again.