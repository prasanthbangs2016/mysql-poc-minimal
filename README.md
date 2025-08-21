# MySQL POC (Minimal)

This is a minimal, beginner-friendly MySQL proof of concept using Docker and Adminer.

What you’ll get
- MySQL 8 running locally via Docker
- Adminer web UI to browse and run SQL
- Auto-created sample schema (customers, orders) with some sample data
- A helpful index for fast lookups

Prerequisites
- Docker Desktop installed and running

Quick start
1) Copy env file
   cp .env.example .env
   # Optionally edit passwords in .env

2) Start MySQL and Adminer
   docker compose up -d
   # Wait ~20–40 seconds for MySQL to initialize (it will auto-run sql/01_init.sql)

3) Open Adminer (web UI)
   - URL: http://localhost:8080
   - System: MySQL
   - Server: db
   - Username: app
   - Password: changeme-app (or your .env value)
   - Database: pocdb

4) Try a few queries (in Adminer → SQL)
   - SELECT COUNT(*) FROM customers;
   - SELECT COUNT(*) FROM orders;

   Get Alice’s recent orders:
   SELECT o.id, o.status, o.placed_at
   FROM orders o
   JOIN customers c ON c.id = o.customer_id
   WHERE c.email = 'alice@example.com'
   ORDER BY o.placed_at DESC;

5) Connect via terminal (optional)
   docker compose exec -it db mysql -uapp -p pocdb

What to demo
- Show tables (customers, orders)
- Explain primary key, foreign key, and the composite index (customer_id, placed_at)
- Run a SELECT with ORDER BY placed_at and show it’s fast
- Show EXPLAIN on a query to see index usage

Resetting data (re-run init script)
- docker compose down -v
- docker compose up -d
This recreates the database and re-runs sql/01_init.sql.

Troubleshooting
- Adminer not loading? Wait 20–40s after “up -d”, then refresh.
- Login fails? Check .env credentials and use Server: db
- “docker: command not found”? Install Docker Desktop and restart your terminal.
