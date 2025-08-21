/* MSSQL init script: creates database, tables, index, and sample data */

-- Create database if not exists
IF DB_ID(N'pocdb') IS NULL
BEGIN
  CREATE DATABASE pocdb;
END
GO

USE pocdb;
GO

SET NOCOUNT ON;

-- Create tables
IF OBJECT_ID(N'dbo.customers', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.customers (
    id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_customers_created_at DEFAULT SYSUTCDATETIME()
  );
END;

IF OBJECT_ID(N'dbo.orders', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.orders (
    id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    status VARCHAR(10) NOT NULL
      CONSTRAINT CK_orders_status CHECK (status IN ('PENDING','PAID','SHIPPED','CANCELLED')),
    placed_at DATETIME2 NOT NULL CONSTRAINT DF_orders_placed_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_orders_customer FOREIGN KEY (customer_id)
      REFERENCES dbo.customers(id)
      ON UPDATE CASCADE
      ON DELETE NO ACTION
  );
END;

-- Composite index for common query (by customer and date)
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = N'ix_orders_customer_placed'
    AND object_id = OBJECT_ID(N'dbo.orders')
)
BEGIN
  CREATE INDEX ix_orders_customer_placed
    ON dbo.orders(customer_id, placed_at);
END;

-- Seed customers (UPSERT via MERGE)
MERGE dbo.customers AS t
USING (VALUES
  ('alice@example.com','Alice'),
  ('bob@example.com','Bob'),
  ('carol@example.com','Carol')
) AS s(email, full_name)
ON t.email = s.email
WHEN MATCHED THEN
  UPDATE SET full_name = s.full_name
WHEN NOT MATCHED THEN
  INSERT (email, full_name) VALUES (s.email, s.full_name);

-- Seed orders: 3 per customer with random recent dates
INSERT INTO dbo.orders (customer_id, status, placed_at)
SELECT c.id, 'PAID',
       DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 30, SYSUTCDATETIME())
FROM dbo.customers c
UNION ALL
SELECT c.id, 'SHIPPED',
       DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 30, SYSUTCDATETIME())
FROM dbo.customers c
UNION ALL
SELECT c.id, 'PENDING',
       DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 30, SYSUTCDATETIME())
FROM dbo.customers c;

-- Basic checks
SELECT
  (SELECT COUNT(*) FROM dbo.customers) AS customers,
  (SELECT COUNT(*) FROM dbo.orders) AS orders_count;

-- Example query:
-- SELECT o.id, o.status, o.placed_at
-- FROM dbo.orders o
-- JOIN dbo.customers c ON c.id = o.customer_id
-- WHERE c.email = 'alice@example.com'
-- ORDER BY o.placed_at DESC;