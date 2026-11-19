# Dawaya Pharmacy - Business Questions

**From:** Tarek El-Sayed, VP of Operations  
**Data:** your normalized database, loaded from `flat_sales_export.csv` (1 July - 30 September 2026). All amounts are in Egyptian pounds (EGP).

For each question, write the SQL query (save all of them in `queries.sql`) and one or two sentences of business insight.

---

## Part 1: Filtering and sorting (`WHERE`, `AND`/`OR`, `ORDER BY`)

### Question 1
List every product whose current unit price is above EGP 300, with its category, sorted from the most expensive.

```sql
SELECT
    p.sku,
    p.product_name,
    c.category_name,
    p.current_unit_price
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
WHERE p.current_unit_price > 300
ORDER BY p.current_unit_price DESC;
```

**Business insight:**


### Question 2
List all transactions at Dawaya Heliopolis in August 2026 with their date, pharmacist and payment method, newest first.

```sql
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
```

**Business insight:**


### Question 3
List the guest checkouts (no loyalty customer) that were paid in cash at Dawaya Nasr City or Dawaya Dokki, sorted by date.

```sql
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
```

**Business insight:**


---

## Part 2: Aggregation (`GROUP BY`, `HAVING`, `SUM`, `COUNT`, `AVG`)

### Question 4
For each branch, show the total revenue and the number of transactions. Show only branches with more than 35 transactions, highest revenue first.

```sql
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
```

**Business insight:**


### Question 5
For each product category, show the total quantity sold and the average unit price. Show only categories with more than 90 units sold.

```sql
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
```

**Business insight:**


### Question 6
For each pharmacist, show the total revenue they handled and their average transaction value. Show only pharmacists above EGP 15,000.

```sql
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
```

**Business insight:**


---

## Part 3: Joins across three or more tables (`INNER JOIN`, `LEFT JOIN`, table aliases)

### Question 7
Who are the top 10 loyalty customers by total spend? Show name, phone, number of visits and total spent.

```sql
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
```

**Business insight:**


### Question 8
Print an itemized receipt for transaction `TXN-7009`: date, branch, pharmacist, customer, each product with quantity, unit price and line total.

```sql
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
```

**Business insight:**


### Question 9
For Dawaya Smouha, list every product sold with its category and total quantity, sorted by category and then by quantity (highest first).

```sql
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
```

**Business insight:**


### Question 10
List every branch with each of its pharmacists and the revenue each pharmacist handled. Branches and pharmacists with no sales (such as the new Dawaya New Capital branch in `data_dictionary.md`) must still appear, with 0 revenue.

```sql
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
```

**Business insight:**

