-- ============================================================================
-- Dawaya Pharmacy - Normalized Database Schema (3NF)
-- ============================================================================

DROP TABLE IF EXISTS sale_items CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS pharmacists CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS branches CASCADE;

-- 1. Branches
CREATE TABLE branches (
    branch_id SERIAL PRIMARY KEY,
    branch_code VARCHAR(10) UNIQUE NOT NULL,
    branch_name VARCHAR(100) UNIQUE NOT NULL,
    branch_address VARCHAR(255) NOT NULL
);

-- 2. Pharmacists
CREATE TABLE pharmacists (
    pharmacist_id SERIAL PRIMARY KEY,
    pharmacist_code VARCHAR(10) UNIQUE NOT NULL,
    pharmacist_name VARCHAR(100) NOT NULL,
    branch_id INT NOT NULL REFERENCES branches(branch_id) ON DELETE RESTRICT
);

-- 3. Customers (Loyalty Members)
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_code VARCHAR(15) UNIQUE NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_phone VARCHAR(20) UNIQUE NOT NULL
);

-- 4. Categories
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL
);

-- 5. Products
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    sku VARCHAR(15) UNIQUE NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL REFERENCES categories(category_id) ON DELETE RESTRICT,
    current_unit_price NUMERIC(10, 2) NOT NULL CHECK (current_unit_price > 0)
);

-- 6. Sales (Transaction Header)
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    transaction_code VARCHAR(15) UNIQUE NOT NULL,
    transaction_date TIMESTAMP NOT NULL,
    branch_id INT NOT NULL REFERENCES branches(branch_id) ON DELETE RESTRICT,
    pharmacist_id INT NOT NULL REFERENCES pharmacists(pharmacist_id) ON DELETE RESTRICT,
    customer_id INT NULL REFERENCES customers(customer_id) ON DELETE SET NULL,
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('Cash', 'Card', 'InstaPay'))
);

-- 7. Sale Items (Transaction Line Items)
CREATE TABLE sale_items (
    sale_item_id SERIAL PRIMARY KEY,
    sale_id INT NOT NULL REFERENCES sales(sale_id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
    quantity_sold INT NOT NULL CHECK (quantity_sold >= 1),
    total_line_price NUMERIC(10, 2) NOT NULL CHECK (total_line_price > 0),
    CONSTRAINT uq_sale_product UNIQUE (sale_id, product_id)
);