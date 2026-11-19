-- ============================================================================
-- Dawaya Pharmacy - Analytical Business Queries
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PART 1: Filtering and Sorting
-- ----------------------------------------------------------------------------

-- Question 1: Products with current unit price above EGP 300, with category, most expensive first
SELECT
    p.sku,
    p.product_name,
    c.category_name,
    p.current_unit_price
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
WHERE p.current_unit_price > 300
ORDER BY p.current_unit_price DESC;

-- Question 2: All transactions at Dawaya Heliopolis in August 2026, newest first
SELECT
    s.transaction_code,
    s.transaction_date,
    ph.pharmacist_name,
    s.payment_method
FROM sales s
INNER JOIN branches b ON s.branch_id = b.branch_id
INNER JOIN pharmacists ph ON s.pharmacist_id = ph.pharmacist_id
WHERE b.branch_name = 'Dawaya Heliopolis'
  AND s.transaction_date >= '2026-08-01 00:00:00'
  AND s.transaction_date < '2026-09-01 00:00:00'
ORDER BY s.transaction_date DESC;

-- Question 3: Guest checkouts paid in cash at Dawaya Nasr City or Dawaya Dokki, sorted by date
SELECT
    s.transaction_code,
    s.transaction_date,
    b.branch_name,
    ph.pharmacist_name,
    s.payment_method
FROM sales s
INNER JOIN branches b ON s.branch_id = b.branch_id
INNER JOIN pharmacists ph ON s.pharmacist_id = ph.pharmacist_id
WHERE s.customer_id IS NULL
  AND s.payment_method = 'Cash'
  AND (b.branch_name = 'Dawaya Nasr City' OR b.branch_name = 'Dawaya Dokki')
ORDER BY s.transaction_date ASC;

-- ----------------------------------------------------------------------------
-- PART 2: Aggregation (GROUP BY, HAVING, SUM, COUNT, AVG)
-- ----------------------------------------------------------------------------

-- Question 4: Total revenue and transaction count per branch (> 35 transactions), highest revenue first
SELECT
    b.branch_name,
    COUNT(DISTINCT s.sale_id) AS transaction_count,
    SUM(si.total_line_price) AS total_revenue
FROM branches b
INNER JOIN sales s ON b.branch_id = s.branch_id
INNER JOIN sale_items si ON s.sale_id = si.sale_id
GROUP BY b.branch_id, b.branch_name
HAVING COUNT(DISTINCT s.sale_id) > 35
ORDER BY total_revenue DESC;

-- Question 5: Total quantity sold and average unit price per category (> 90 units sold)
SELECT
    c.category_name,
    SUM(si.quantity_sold) AS total_quantity_sold,
    ROUND(AVG(si.unit_price), 2) AS average_unit_price
FROM categories c
INNER JOIN products p ON c.category_id = p.category_id
INNER JOIN sale_items si ON p.product_id = si.product_id
GROUP BY c.category_id, c.category_name
HAVING SUM(si.quantity_sold) > 90
ORDER BY total_quantity_sold DESC;

-- Question 6: Total revenue and average transaction value per pharmacist (> EGP 15,000)
SELECT
    ph.pharmacist_name,
    b.branch_name,
    SUM(si.total_line_price) AS total_revenue,
    ROUND(SUM(si.total_line_price) / COUNT(DISTINCT s.sale_id), 2) AS avg_transaction_value
FROM pharmacists ph
INNER JOIN branches b ON ph.branch_id = b.branch_id
INNER JOIN sales s ON ph.pharmacist_id = s.pharmacist_id
INNER JOIN sale_items si ON s.sale_id = si.sale_id
GROUP BY ph.pharmacist_id, ph.pharmacist_name, b.branch_name
HAVING SUM(si.total_line_price) > 15000
ORDER BY total_revenue DESC;

-- ----------------------------------------------------------------------------
-- PART 3: Joins Across Three or More Tables
-- ----------------------------------------------------------------------------

-- Question 7: Top 10 loyalty customers by total spend
SELECT
    cu.customer_name,
    cu.customer_phone,
    COUNT(DISTINCT s.sale_id) AS number_of_visits,
    SUM(si.total_line_price) AS total_spent
FROM customers cu
INNER JOIN sales s ON cu.customer_id = s.customer_id
INNER JOIN sale_items si ON s.sale_id = si.sale_id
GROUP BY cu.customer_id, cu.customer_name, cu.customer_phone
ORDER BY total_spent DESC
LIMIT 10;

-- Question 8: Itemized receipt for transaction TXN-7009
SELECT
    s.transaction_date,
    b.branch_name,
    ph.pharmacist_name,
    COALESCE(cu.customer_name, 'Guest') AS customer_name,
    p.product_name,
    si.quantity_sold,
    si.unit_price,
    si.total_line_price
FROM sales s
INNER JOIN branches b ON s.branch_id = b.branch_id
INNER JOIN pharmacists ph ON s.pharmacist_id = ph.pharmacist_id
LEFT JOIN customers cu ON s.customer_id = cu.customer_id
INNER JOIN sale_items si ON s.sale_id = si.sale_id
INNER JOIN products p ON si.product_id = p.product_id
WHERE s.transaction_code = 'TXN-7009'
ORDER BY si.sale_item_id ASC;

-- Question 9: Products sold at Dawaya Smouha with category and total quantity
SELECT
    c.category_name,
    p.product_name,
    SUM(si.quantity_sold) AS total_quantity
FROM branches b
INNER JOIN sales s ON b.branch_id = s.branch_id
INNER JOIN sale_items si ON s.sale_id = si.sale_id
INNER JOIN products p ON si.product_id = p.product_id
INNER JOIN categories c ON p.category_id = c.category_id
WHERE b.branch_name = 'Dawaya Smouha'
GROUP BY c.category_name, p.product_name
ORDER BY c.category_name ASC, total_quantity DESC;

-- Question 10: Every branch with each pharmacist and their handled revenue (including 0 revenue)
SELECT
    b.branch_code,
    b.branch_name,
    ph.pharmacist_code,
    ph.pharmacist_name,
    COALESCE(SUM(si.total_line_price), 0) AS total_revenue
FROM branches b
LEFT JOIN pharmacists ph ON b.branch_id = ph.branch_id
LEFT JOIN sales s ON ph.pharmacist_id = s.pharmacist_id
LEFT JOIN sale_items si ON s.sale_id = si.sale_id
GROUP BY b.branch_id, b.branch_code, b.branch_name, ph.pharmacist_id, ph.pharmacist_code, ph.pharmacist_name
ORDER BY b.branch_code ASC, total_revenue DESC;