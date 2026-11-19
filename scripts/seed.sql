-- ============================================================================
-- Dawaya Pharmacy - Data Cleaning & Migration Script
-- ============================================================================

BEGIN;

-- 1. Temporary Staging Table
CREATE TEMP TABLE staging_sales (
    transaction_id VARCHAR(20),
    transaction_date TIMESTAMP,
    branch_id VARCHAR(10),
    branch_name VARCHAR(100),
    branch_address VARCHAR(255),
    pharmacist_id VARCHAR(10),
    pharmacist_name VARCHAR(100),
    customer_id VARCHAR(20),
    customer_name VARCHAR(100),
    customer_phone VARCHAR(30),
    payment_method VARCHAR(20),
    product_id VARCHAR(20),
    product_name VARCHAR(150),
    category_name VARCHAR(100),
    unit_price NUMERIC(10, 2),
    quantity_sold INT,
    total_line_price NUMERIC(10, 2)
);

-- 2. Load Raw CSV into Staging
\copy staging_sales FROM 'data/flat_sales_export.csv' WITH (FORMAT csv, HEADER true, NULL '');

-- 3. Deduplicate Exact Rows (Removes duplicate lines in TXN-7199 & TXN-7426)
CREATE TEMP TABLE clean_staging AS
SELECT DISTINCT * FROM staging_sales;

-- 4. Populate Branches (Canonical Names/Addresses + New Capital BR-07)
INSERT INTO branches (branch_code, branch_name, branch_address)
SELECT DISTINCT
    branch_id,
    TRIM(branch_name),
    CASE branch_id
        WHEN 'BR-01' THEN '12 El-Merghany St, Heliopolis, Cairo'
        ELSE TRIM(branch_address)
    END
FROM clean_staging
ORDER BY branch_id;

INSERT INTO branches (branch_code, branch_name, branch_address)
VALUES ('BR-07', 'Dawaya New Capital', 'Downtown Mall, R7, New Administrative Capital');

-- 5. Populate Pharmacists (Standardized Spelling + Mai Hossam PH-0113)
INSERT INTO pharmacists (pharmacist_code, pharmacist_name, branch_id)
SELECT DISTINCT
    s.pharmacist_id,
    CASE s.pharmacist_id
        WHEN 'PH-0102' THEN 'Mohamed Saber'
        ELSE TRIM(s.pharmacist_name)
    END,
    b.branch_id
FROM clean_staging s
JOIN branches b ON s.branch_id = b.branch_code
ORDER BY s.pharmacist_id;

INSERT INTO pharmacists (pharmacist_code, pharmacist_name, branch_id)
SELECT 'PH-0113', 'Mai Hossam', branch_id
FROM branches WHERE branch_code = 'BR-07';

-- 6. Populate Customers (Standardized Egyptian Phone Format: 01XXXXXXXXX)
INSERT INTO customers (customer_code, customer_name, customer_phone)
SELECT DISTINCT
    customer_id,
    TRIM(customer_name),
    REGEXP_REPLACE(REPLACE(TRIM(customer_phone), ' ', ''), '^\+20', '0')
FROM clean_staging
WHERE customer_id IS NOT NULL
ORDER BY customer_id;

-- 7. Populate Categories
INSERT INTO categories (category_name)
SELECT DISTINCT TRIM(category_name)
FROM clean_staging
ORDER BY TRIM(category_name);

-- 8. Populate Products (Canonical Names & Latest Official Unit Price)
INSERT INTO products (sku, product_name, category_id, current_unit_price)
SELECT DISTINCT ON (s.product_id)
    s.product_id,
    CASE s.product_id
        WHEN 'SKU-1001' THEN 'Panadol Extra 24 Tabs'
        WHEN 'SKU-1007' THEN 'Concor 5mg 30 Tabs'
        WHEN 'SKU-1010' THEN 'Glucophage 1000mg 30 Tabs'
        WHEN 'SKU-1029' THEN 'Pampers Size 4 (52 pcs)'
        ELSE TRIM(s.product_name)
    END,
    c.category_id,
    s.unit_price
FROM clean_staging s
JOIN categories c ON TRIM(s.category_name) = c.category_name
ORDER BY s.product_id, s.transaction_date DESC;

-- 9. Populate Sales (Transaction Headers)
INSERT INTO sales (transaction_code, transaction_date, branch_id, pharmacist_id, customer_id, payment_method)
SELECT DISTINCT
    s.transaction_id,
    s.transaction_date,
    b.branch_id,
    ph.pharmacist_id,
    cu.customer_id,
    TRIM(s.payment_method)
FROM clean_staging s
JOIN branches b ON s.branch_id = b.branch_code
JOIN pharmacists ph ON s.pharmacist_id = ph.pharmacist_code
LEFT JOIN customers cu ON s.customer_id = cu.customer_code
ORDER BY s.transaction_date, s.transaction_id;

-- 10. Populate Sale Items (Recalculated Line Totals to Fix Manual Entry Errors)
INSERT INTO sale_items (sale_id, product_id, unit_price, quantity_sold, total_line_price)
SELECT
    sa.sale_id,
    p.product_id,
    s.unit_price,
    s.quantity_sold,
    ROUND(s.unit_price * s.quantity_sold, 2)
FROM clean_staging s
JOIN sales sa ON s.transaction_id = sa.transaction_code
JOIN products p ON s.product_id = p.sku
ORDER BY sa.sale_id, p.product_id;

COMMIT;