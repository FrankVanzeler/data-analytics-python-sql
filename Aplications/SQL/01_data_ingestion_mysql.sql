-- =====================================================
-- 01_data_ingestion_mysql.sql
-- Brazilian E-Commerce Analytics Portfolio
-- SQL version of notebook 01_data_ingestion.ipynb
--
-- Purpose:
--   1. Create a MySQL schema for the Olist e-commerce dataset.
--   2. Create raw relational tables that match the CSV structure.
--   3. Provide ingestion validation queries:
--      - table counts
--      - schema checks
--      - key checks
--      - parent-child relationship checks
--      - date-field completeness checks
--
-- Notes:
--   - This script does not import the CSV files automatically.
--   - Import the CSV files with MySQL Workbench Table Data Import Wizard
--     or with LOAD DATA LOCAL INFILE if local-infile is enabled.
--   - The raw tables intentionally avoid strict foreign-key constraints.
--     This allows the analyst to import the raw data first and validate
--     relationship consistency afterward.
--   - All column names match the original Olist CSV files.
-- =====================================================

USE olist_ecommerce_analytics;

DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS sellers;
DROP TABLE IF EXISTS category_translation;
-- =====================================================
-- 1. DATABASE CREATION
-- =====================================================

CREATE DATABASE IF NOT EXISTS olist_ecommerce_analytics;

USE olist_ecommerce_analytics;



-- =====================================================
-- 2. RAW TABLE CREATION
-- =====================================================

CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(40),
    customer_unique_id VARCHAR(40),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(2)
);


CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(40),
    customer_id VARCHAR(40),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);


CREATE TABLE IF NOT EXISTS order_items (
    order_id VARCHAR(40),
    order_item_id INT,
    product_id VARCHAR(40),
    seller_id VARCHAR(40),
    shipping_limit_date DATETIME,
    price DECIMAL(12, 2),
    freight_value DECIMAL(12, 2)
);


CREATE TABLE IF NOT EXISTS payments (
    order_id VARCHAR(40),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(12, 2)
);


CREATE TABLE IF NOT EXISTS reviews (
    review_id VARCHAR(40),
    order_id VARCHAR(40),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);


CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(40),
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);


CREATE TABLE IF NOT EXISTS sellers (
    seller_id VARCHAR(40),
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(2)
);


CREATE TABLE IF NOT EXISTS category_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);


-- =====================================================
-- 3. OPTIONAL RESET COMMANDS
-- =====================================================
-- WARNING:
-- Uncomment this block only if you want to remove all imported rows.
--
-- TRUNCATE TABLE reviews;
-- TRUNCATE TABLE payments;
-- TRUNCATE TABLE order_items;
-- TRUNCATE TABLE orders;
-- TRUNCATE TABLE customers;
-- TRUNCATE TABLE products;
-- TRUNCATE TABLE sellers;
-- TRUNCATE TABLE category_translation;

USE olist_ecommerce_analytics;

TRUNCATE TABLE reviews;
TRUNCATE TABLE payments;
TRUNCATE TABLE order_items;
TRUNCATE TABLE orders;
TRUNCATE TABLE customers;
TRUNCATE TABLE products;
TRUNCATE TABLE sellers;
TRUNCATE TABLE category_translation;


-- =====================================================
-- 4. RECOMMENDED CSV IMPORT ORDER
-- =====================================================
-- Import the raw CSV files into the existing tables in this order:
--
-- 1. customers
--    File: olist_customers_dataset.csv
--
-- 2. orderscustomers
--    File: olist_orders_dataset.csv
--
-- 3. products
--    File: olist_products_dataset.csv
--
-- 4. sellers
--    File: olist_sellers_dataset.csv
--
-- 5. category_translation
--    File: product_category_name_translation.csv
--
-- 6. order_items
--    File: olist_order_items_dataset.csv
--
-- 7. payments
--    File: olist_order_payments_dataset.csv
--
-- 8. reviews
--    File: olist_order_reviews_dataset.csv


-- =====================================================
-- 5. TABLE COUNTS
-- =====================================================

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'category_translation', COUNT(*) FROM category_translation;


-- =====================================================
-- 6. EXPECTED COLUMN VALIDATION
-- =====================================================
-- This checks whether each expected column exists in the MySQL schema.

WITH expected_columns AS (
    SELECT 'customers' AS table_name, 'customer_id' AS column_name UNION ALL
    SELECT 'customers', 'customer_unique_id' UNION ALL
    SELECT 'customers', 'customer_zip_code_prefix' UNION ALL
    SELECT 'customers', 'customer_city' UNION ALL
    SELECT 'customers', 'customer_state' UNION ALL

    SELECT 'orders', 'order_id' UNION ALL
    SELECT 'orders', 'customer_id' UNION ALL
    SELECT 'orders', 'order_status' UNION ALL
    SELECT 'orders', 'order_purchase_timestamp' UNION ALL
    SELECT 'orders', 'order_approved_at' UNION ALL
    SELECT 'orders', 'order_delivered_carrier_date' UNION ALL
    SELECT 'orders', 'order_delivered_customer_date' UNION ALL
    SELECT 'orders', 'order_estimated_delivery_date' UNION ALL

    SELECT 'order_items', 'order_id' UNION ALL
    SELECT 'order_items', 'order_item_id' UNION ALL
    SELECT 'order_items', 'product_id' UNION ALL
    SELECT 'order_items', 'seller_id' UNION ALL
    SELECT 'order_items', 'shipping_limit_date' UNION ALL
    SELECT 'order_items', 'price' UNION ALL
    SELECT 'order_items', 'freight_value' UNION ALL

    SELECT 'payments', 'order_id' UNION ALL
    SELECT 'payments', 'payment_sequential' UNION ALL
    SELECT 'payments', 'payment_type' UNION ALL
    SELECT 'payments', 'payment_installments' UNION ALL
    SELECT 'payments', 'payment_value' UNION ALL

    SELECT 'reviews', 'review_id' UNION ALL
    SELECT 'reviews', 'order_id' UNION ALL
    SELECT 'reviews', 'review_score' UNION ALL
    SELECT 'reviews', 'review_comment_title' UNION ALL
    SELECT 'reviews', 'review_comment_message' UNION ALL
    SELECT 'reviews', 'review_creation_date' UNION ALL
    SELECT 'reviews', 'review_answer_timestamp' UNION ALL

    SELECT 'products', 'product_id' UNION ALL
    SELECT 'products', 'product_category_name' UNION ALL
    SELECT 'products', 'product_name_lenght' UNION ALL
    SELECT 'products', 'product_description_lenght' UNION ALL
    SELECT 'products', 'product_photos_qty' UNION ALL
    SELECT 'products', 'product_weight_g' UNION ALL
    SELECT 'products', 'product_length_cm' UNION ALL
    SELECT 'products', 'product_height_cm' UNION ALL
    SELECT 'products', 'product_width_cm' UNION ALL

    SELECT 'sellers', 'seller_id' UNION ALL
    SELECT 'sellers', 'seller_zip_code_prefix' UNION ALL
    SELECT 'sellers', 'seller_city' UNION ALL
    SELECT 'sellers', 'seller_state' UNION ALL

    SELECT 'category_translation', 'product_category_name' UNION ALL
    SELECT 'category_translation', 'product_category_name_english'
)

SELECT
    e.table_name,
    e.column_name,
    CASE
        WHEN c.column_name IS NULL THEN 'missing'
        ELSE 'present'
    END AS column_status
FROM expected_columns AS e
LEFT JOIN information_schema.columns AS c
    ON c.table_schema = DATABASE()
   AND c.table_name = e.table_name
   AND c.column_name = e.column_name
ORDER BY e.table_name, e.column_name;


-- =====================================================
-- 7. MISSING VALUE SUMMARY
-- =====================================================

SELECT
    'customers' AS table_name,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(customer_unique_id IS NULL) AS missing_customer_unique_id,
    SUM(customer_city IS NULL) AS missing_customer_city,
    SUM(customer_state IS NULL) AS missing_customer_state
FROM customers;

SELECT
    'orders' AS table_name,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(order_status IS NULL) AS missing_order_status,
    SUM(order_purchase_timestamp IS NULL) AS missing_purchase_timestamp,
    SUM(order_approved_at IS NULL) AS missing_approved_at,
    SUM(order_delivered_carrier_date IS NULL) AS missing_delivered_carrier_date,
    SUM(order_delivered_customer_date IS NULL) AS missing_delivered_customer_date,
    SUM(order_estimated_delivery_date IS NULL) AS missing_estimated_delivery_date
FROM orders;

SELECT
    'order_items' AS table_name,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(order_item_id IS NULL) AS missing_order_item_id,
    SUM(product_id IS NULL) AS missing_product_id,
    SUM(seller_id IS NULL) AS missing_seller_id,
    SUM(shipping_limit_date IS NULL) AS missing_shipping_limit_date,
    SUM(price IS NULL) AS missing_price,
    SUM(freight_value IS NULL) AS missing_freight_value
FROM order_items;

SELECT
    'payments' AS table_name,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(payment_sequential IS NULL) AS missing_payment_sequential,
    SUM(payment_type IS NULL) AS missing_payment_type,
    SUM(payment_installments IS NULL) AS missing_payment_installments,
    SUM(payment_value IS NULL) AS missing_payment_value
FROM payments;

SELECT
    'reviews' AS table_name,
    SUM(review_id IS NULL) AS missing_review_id,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(review_score IS NULL) AS missing_review_score,
    SUM(review_comment_title IS NULL) AS missing_review_comment_title,
    SUM(review_comment_message IS NULL) AS missing_review_comment_message,
    SUM(review_creation_date IS NULL) AS missing_review_creation_date,
    SUM(review_answer_timestamp IS NULL) AS missing_review_answer_timestamp
FROM reviews;

SELECT
    'products' AS table_name,
    SUM(product_id IS NULL) AS missing_product_id,
    SUM(product_category_name IS NULL) AS missing_product_category_name,
    SUM(product_name_lenght IS NULL) AS missing_product_name_lenght,
    SUM(product_description_lenght IS NULL) AS missing_product_description_lenght,
    SUM(product_photos_qty IS NULL) AS missing_product_photos_qty,
    SUM(product_weight_g IS NULL) AS missing_product_weight_g,
    SUM(product_length_cm IS NULL) AS missing_product_length_cm,
    SUM(product_height_cm IS NULL) AS missing_product_height_cm,
    SUM(product_width_cm IS NULL) AS missing_product_width_cm
FROM products;

SELECT
    'sellers' AS table_name,
    SUM(seller_id IS NULL) AS missing_seller_id,
    SUM(seller_zip_code_prefix IS NULL) AS missing_seller_zip_code_prefix,
    SUM(seller_city IS NULL) AS missing_seller_city,
    SUM(seller_state IS NULL) AS missing_seller_state
FROM sellers;


-- =====================================================
-- 8. DUPLICATE KEY CHECKS
-- =====================================================

SELECT
    'customers' AS table_name,
    'customer_id' AS key_name,
    COUNT(*) AS duplicate_key_groups
FROM (
    SELECT customer_id
    FROM customers
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) AS duplicated_keys

UNION ALL

SELECT
    'orders',
    'order_id',
    COUNT(*)
FROM (
    SELECT order_id
    FROM orders
    GROUP BY order_id
    HAVING COUNT(*) > 1
) AS duplicated_keys

UNION ALL

SELECT
    'order_items',
    'order_id + order_item_id',
    COUNT(*)
FROM (
    SELECT order_id, order_item_id
    FROM order_items
    GROUP BY order_id, order_item_id
    HAVING COUNT(*) > 1
) AS duplicated_keys

UNION ALL

SELECT
    'payments',
    'order_id + payment_sequential',
    COUNT(*)
FROM (
    SELECT order_id, payment_sequential
    FROM payments
    GROUP BY order_id, payment_sequential
    HAVING COUNT(*) > 1
) AS duplicated_keys

UNION ALL

SELECT
    'products',
    'product_id',
    COUNT(*)
FROM (
    SELECT product_id
    FROM products
    GROUP BY product_id
    HAVING COUNT(*) > 1
) AS duplicated_keys

UNION ALL

SELECT
    'sellers',
    'seller_id',
    COUNT(*)
FROM (
    SELECT seller_id
    FROM sellers
    GROUP BY seller_id
    HAVING COUNT(*) > 1
) AS duplicated_keys

UNION ALL

SELECT
    'category_translation',
    'product_category_name',
    COUNT(*)
FROM (
    SELECT product_category_name
    FROM category_translation
    GROUP BY product_category_name
    HAVING COUNT(*) > 1
) AS duplicated_keys;


-- =====================================================
-- 9. PARENT-CHILD RELATIONSHIP CHECKS
-- =====================================================

SELECT
    'orders.customer_id -> customers.customer_id' AS relationship_name,
    COUNT(DISTINCT o.customer_id) AS orphan_key_count
FROM orders AS o
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT
    'order_items.order_id -> orders.order_id',
    COUNT(DISTINCT oi.order_id)
FROM order_items AS oi
LEFT JOIN orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'payments.order_id -> orders.order_id',
    COUNT(DISTINCT p.order_id)
FROM payments AS p
LEFT JOIN orders AS o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'reviews.order_id -> orders.order_id',
    COUNT(DISTINCT r.order_id)
FROM reviews AS r
LEFT JOIN orders AS o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'order_items.product_id -> products.product_id',
    COUNT(DISTINCT oi.product_id)
FROM order_items AS oi
LEFT JOIN products AS pr
    ON oi.product_id = pr.product_id
WHERE pr.product_id IS NULL

UNION ALL

SELECT
    'order_items.seller_id -> sellers.seller_id',
    COUNT(DISTINCT oi.seller_id)
FROM order_items AS oi
LEFT JOIN sellers AS s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL

UNION ALL

SELECT
    'products.product_category_name -> category_translation.product_category_name',
    COUNT(DISTINCT pr.product_category_name)
FROM products AS pr
LEFT JOIN category_translation AS ct
    ON pr.product_category_name = ct.product_category_name
WHERE pr.product_category_name IS NOT NULL
  AND ct.product_category_name IS NULL;


-- =====================================================
-- 10. DATE RANGE SUMMARY
-- =====================================================

SELECT
    MIN(order_purchase_timestamp) AS first_purchase_timestamp,
    MAX(order_purchase_timestamp) AS last_purchase_timestamp,
    MIN(order_delivered_customer_date) AS first_customer_delivery_timestamp,
    MAX(order_delivered_customer_date) AS last_customer_delivery_timestamp,
    MIN(order_estimated_delivery_date) AS first_estimated_delivery_timestamp,
    MAX(order_estimated_delivery_date) AS last_estimated_delivery_timestamp
FROM orders;


-- =====================================================
-- 11. ORDER STATUS DISTRIBUTION
-- =====================================================

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- =====================================================
-- 12. PAYMENT TYPE DISTRIBUTION
-- =====================================================

SELECT
    payment_type,
    COUNT(*) AS payment_record_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM payments
GROUP BY payment_type
ORDER BY payment_record_count DESC;


-- =====================================================
-- 13. REVIEW SCORE DISTRIBUTION
-- =====================================================

SELECT
    review_score,
    COUNT(*) AS review_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM reviews
GROUP BY review_score
ORDER BY review_score;


-- =====================================================
-- 14. BASIC NUMERIC RANGE CHECKS
-- =====================================================

SELECT
    'order_items.price' AS field_name,
    MIN(price) AS minimum_value,
    MAX(price) AS maximum_value,
    SUM(price < 0) AS negative_value_count
FROM order_items

UNION ALL

SELECT
    'order_items.freight_value',
    MIN(freight_value),
    MAX(freight_value),
    SUM(freight_value < 0)
FROM order_items

UNION ALL

SELECT
    'payments.payment_value',
    MIN(payment_value),
    MAX(payment_value),
    SUM(payment_value < 0)
FROM payments

UNION ALL

SELECT
    'payments.payment_installments',
    MIN(payment_installments),
    MAX(payment_installments),
    SUM(payment_installments < 0)
FROM payments

UNION ALL

SELECT
    'reviews.review_score',
    MIN(review_score),
    MAX(review_score),
    SUM(review_score NOT BETWEEN 1 AND 5)
FROM reviews;


-- =====================================================
-- 15. INGESTION SUMMARY VIEW
-- =====================================================

CREATE OR REPLACE VIEW ingestion_table_counts AS
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'category_translation', COUNT(*) FROM category_translation;

SELECT *
FROM ingestion_table_counts
ORDER BY table_name;


-- =====================================================
-- END OF SCRIPT
-- =====================================================
