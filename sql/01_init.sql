-- Minimal schema + sample data

CREATE TABLE IF NOT EXISTS customers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  email VARCHAR(255) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY ux_customers_email (email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id BIGINT UNSIGNED NOT NULL,
  status ENUM('PENDING','PAID','SHIPPED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  placed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY ix_orders_customer_placed (customer_id, placed_at),
  CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
    REFERENCES customers(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Sample customers
INSERT INTO customers (email, full_name)
VALUES
 ('alice@example.com','Alice'),
 ('bob@example.com','Bob'),
 ('carol@example.com','Carol')
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name);

-- A few orders per customer with random-ish dates
INSERT INTO orders (customer_id, status, placed_at)
SELECT id, 'PAID', NOW() - INTERVAL FLOOR(RAND()*30) DAY FROM customers
UNION ALL
SELECT id, 'SHIPPED', NOW() - INTERVAL FLOOR(RAND()*30) DAY FROM customers
UNION ALL
SELECT id, 'PENDING', NOW() - INTERVAL FLOOR(RAND()*30) DAY FROM customers;

-- Basic checks
SELECT
  (SELECT COUNT(*) FROM customers) AS customers,
  (SELECT COUNT(*) FROM orders) AS orders_count;

-- Example query you can run in Adminer:
-- SELECT o.id, o.status, o.placed_at
-- FROM orders o
-- JOIN customers c ON c.id = o.customer_id
-- WHERE c.email = 'alice@example.com'
-- ORDER BY o.placed_at DESC;