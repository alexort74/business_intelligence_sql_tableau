/*
*******************************************************************************
*******************************************************************************

MAGIST DATABASE

*******************************************************************************
*******************************************************************************

Data Exploration

*/

USE magist123;

-- 1. How many orders are there in the database?
    
SELECT 
    COUNT(order_id)
FROM
    orders;

-- 2. Are orders actually delivered?

SELECT 
    order_status, COUNT(order_status) AS count_order_status,
    ROUND(
    100.0
    * COUNT(order_status)
    / SUM(COUNT(order_status)) OVER () 
  ,2) AS pct_of_total
FROM
    orders
GROUP BY order_status
ORDER BY count_order_status DESC;

-- 3. Is Magist having user growth?

SELECT 
    YEAR(order_purchase_timestamp) AS order_year,
    MONTH(order_purchase_timestamp) AS order_month,
    COUNT(order_id) AS order_count
FROM
    orders
GROUP BY YEAR(order_purchase_timestamp) , MONTH(order_purchase_timestamp)
ORDER BY order_year DESC , order_month DESC;

-- 4. How many products are there on the products table?

SELECT COUNT(product_id) AS product_count
FROM
    products;

-- 5. Which are the categories with the most products?

SELECT 
    product_category_name_english AS category,
    COUNT(product_id) AS count_product_offered
FROM
    products AS p
        LEFT JOIN
    product_category_name_translation AS t ON p.product_category_name = t.product_category_name
GROUP BY product_category_name_english
ORDER BY count_product_offered DESC
LIMIT 20;

-- 6. How many of those products were present in actual transactions?

SELECT 
    product_category_name_english AS category,
    COUNT(DISTINCT i.product_id) AS count_product_ordered
FROM
    order_items AS i
        LEFT JOIN
    products AS p ON i.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation AS t ON p.product_category_name = t.product_category_name
GROUP BY product_category_name_english
ORDER BY count_product_ordered DESC
LIMIT 20;
    
SELECT 
	COUNT(DISTINCT product_id) AS count_product_ordered
FROM
	order_items;

-- 7. What’s the price for the most expensive and cheapest products?

SELECT 
    product_category_name_english AS category, MAX(price) AS max_price
FROM
    order_items AS i
        LEFT JOIN
    products AS p ON i.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation AS t ON p.product_category_name = t.product_category_name
GROUP BY category
ORDER BY max_price DESC
LIMIT 10;

SELECT 
    product_category_name_english AS category, MIN(price) AS min_price
FROM
    order_items AS i
        LEFT JOIN
    products AS p ON i.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation AS t ON p.product_category_name = t.product_category_name
GROUP BY category
ORDER BY min_price ASC
LIMIT 10;

-- 8. What are the highest and lowest payment values?

SELECT 
    MAX(payment_value) AS max_payment, MIN(payment_value) AS min_payment
FROM
    order_payments;


SELECT 
    order_id, ROUND(SUM(payment_value), 2) AS total_order_payment
FROM
    order_payments
GROUP BY order_id
ORDER BY total_order_payment DESC
LIMIT 10;


/*
*******************************************************************************
*******************************************************************************

MAGIST DATABASE

*******************************************************************************
*******************************************************************************

Answer business questions

In relation to the products:

*/

-- 1. What categories of tech products does Magist have?
    
CREATE OR REPLACE VIEW tech_products AS
    SELECT 
        product_category_name,
        product_category_name_english,
        CASE
            WHEN
                product_category_name_english IN ('audio' , 'computers',
                    'computers_accessories',
                    'electronics',
                    'pc_gamer',
                    'tablets_printing_image',
                    'telephony')
            THEN
                'tech_product'
            ELSE 'non_tech_product'
        END AS product_category_type
    FROM
        product_category_name_translation
    ORDER BY product_category_type DESC , product_category_name_english ASC;

-- 2. How many products of these tech categories have been sold (within the time window of the database snapshot)?

SELECT 
    COUNT(DISTINCT i.product_id) AS count_product_sold -- Do I need to put DISTINCT or not?
FROM
    order_items AS i
        LEFT JOIN
    products AS p ON i.product_id = p.product_id
        LEFT JOIN
    tech_products AS t ON p.product_category_name = t.product_category_name
WHERE product_category_type = 'tech_product';

SELECT 
    product_category_name_english AS product_category, product_category_type, 
    COUNT(DISTINCT i.product_id) AS count_product_sold
FROM
    order_items AS i
        LEFT JOIN
    products AS p ON i.product_id = p.product_id
        LEFT JOIN
    tech_products AS t ON p.product_category_name = t.product_category_name
GROUP BY product_category, product_category_type
HAVING product_category_type = 'tech_product'
ORDER BY count_product_sold DESC, product_category ASC;

-- 3. What percentage does that represent from the overall number of products sold?

SELECT 
    COUNT(DISTINCT i.product_id) AS count_product_sold
FROM
    order_items AS i
        LEFT JOIN
    products AS p ON i.product_id = p.product_id
        LEFT JOIN
    tech_products AS t ON p.product_category_name = t.product_category_name;

SELECT 
    product_category_name_english AS product_category, product_category_type, 
    COUNT(DISTINCT i.product_id) AS count_product_ordered,
    ROUND(
    100.0
    * COUNT(DISTINCT i.product_id)
    / SUM(COUNT(DISTINCT i.product_id)) OVER () 
  ,2) AS pct_of_total
FROM
    order_items AS i
        LEFT JOIN
    products AS p ON i.product_id = p.product_id
        LEFT JOIN
    tech_products AS t ON p.product_category_name = t.product_category_name
GROUP BY product_category, product_category_type
ORDER BY product_category_type DESC, pct_of_total DESC;

-- 4. What’s the average price of the products being sold?

SELECT 
    ROUND(AVG(i.price),2) AS avg_price
FROM
    order_items AS i
        LEFT JOIN
    products AS p ON i.product_id = p.product_id
        LEFT JOIN
    tech_products AS t ON p.product_category_name = t.product_category_name;
    
SELECT 
    product_category_type, MAX(price) AS max_price, MIN(price) AS min_price, ROUND(AVG(price),2) AS avg_price
FROM
    order_items AS i
        LEFT JOIN
    products AS p ON i.product_id = p.product_id
        LEFT JOIN
    tech_products AS t ON p.product_category_name = t.product_category_name
GROUP BY product_category_type
ORDER BY product_category_type DESC, avg_price DESC;

SELECT 
    product_category_name_english AS category_name, product_category_type, MAX(price) AS max_price, MIN(price) AS min_price, ROUND(AVG(price),2) AS avg_price
FROM
    order_items AS i
        LEFT JOIN
    products AS p ON i.product_id = p.product_id
        LEFT JOIN
    tech_products AS t ON p.product_category_name = t.product_category_name
GROUP BY category_name, product_category_type
HAVING product_category_type = 'tech_product'
ORDER BY product_category_type DESC, avg_price DESC, category_name ASC;

-- 5. Are expensive tech products popular?

-- How do you define "expensive"?
-- Eniac's average price 540 Euro   

SELECT product_category_type, COUNT(i.product_id) AS count_sales,
    CASE
        WHEN price >= 1000 THEN 'High Price'
        WHEN price >= 500 AND price < 1000 THEN 'Medium Price'
        WHEN price >= 100 AND price < 500 THEN 'Low Price'
        ELSE 'Super Low Price'
    END AS 'price_category'
FROM
    order_items AS i
        LEFT JOIN
    products AS p ON i.product_id = p.product_id
        LEFT JOIN
    tech_products AS t ON p.product_category_name = t.product_category_name
GROUP BY product_category_type, price_category
HAVING product_category_type = 'tech_product'
ORDER BY count_sales DESC;

SELECT 
    product_category_name_english AS category_name, product_category_type, ROUND(AVG(price),2) AS ave_category_price, 
	CASE WHEN AVG(price) >= 1000 THEN 'High Price'
	   WHEN AVG(price) >= 500 AND AVG(price) < 1000 THEN 'Medium Price'
       WHEN AVG(price) >= 100 AND AVG(price) < 500 THEN 'Low Price'
       ELSE 'Super Low Price'
       END AS price_category,
	COUNT(i.product_id) AS count_sales
FROM
    order_items AS i
        LEFT JOIN
    products AS p ON i.product_id = p.product_id
        LEFT JOIN
    tech_products AS t ON p.product_category_name = t.product_category_name
WHERE product_category_type = 'tech_product'
GROUP BY category_name
ORDER BY ave_category_price DESC;

/*
Answer business questions

In relation to the sellers:

*/

-- 6. How many months of data are included in the magist database?

SELECT
  MIN(DATE_FORMAT(order_purchase_timestamp, '%Y-%m')) AS first_month,
  MAX(DATE_FORMAT(order_purchase_timestamp, '%Y-%m')) AS last_month,
  TIMESTAMPDIFF(
    MONTH,
    MIN(order_purchase_timestamp),
    MAX(order_purchase_timestamp)
  ) + 1 AS total_months
FROM orders;

-- 7. How many sellers are there?

SELECT 
    COUNT(seller_id) AS seller_count
FROM
    sellers;
    
SELECT 
    COUNT(DISTINCT seller_id) AS seller_count
FROM
    order_items;
 
 -- 8. How many Tech sellers are there? What percentage of overall sellers are Tech sellers?

SELECT 
    COUNT(DISTINCT i.seller_id) AS seller_count
FROM
    order_items AS i
        LEFT JOIN
    products AS p ON i.product_id = p.product_id
        LEFT JOIN
    tech_products AS t ON p.product_category_name = t.product_category_name
WHERE
    product_category_type = 'tech_product';

SELECT 
    product_category_name_english AS category_name,
    product_category_type,
    COUNT(DISTINCT i.seller_id) AS seller_count
FROM
    order_items AS i
        LEFT JOIN
    products AS p ON i.product_id = p.product_id
        LEFT JOIN
    tech_products AS t ON p.product_category_name = t.product_category_name
WHERE
    product_category_type = 'tech_product'
GROUP BY category_name
ORDER BY seller_count DESC;

-- 9. What is the total amount earned by all sellers?

SELECT 
    ROUND(SUM(price), 2) AS total_earnings
FROM
    order_items AS i
        LEFT JOIN
    orders AS o ON i.order_id = o.order_id
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled');

-- 10. What is the total amount earned by all Tech sellers?

SELECT 
    ROUND(SUM(price), 2) AS tech_sellers_earnings
FROM
    order_items AS i
        LEFT JOIN
    orders AS o ON i.order_id = o.order_id
        LEFT JOIN
    products AS p ON i.product_id = p.product_id
        LEFT JOIN
    tech_products AS t ON p.product_category_name = t.product_category_name
WHERE
    product_category_type = 'tech_product'
        AND o.order_status NOT IN ('unavailable' , 'canceled');

-- 11. Can you work out the average monthly income of all sellers?

SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS purchase_month,
    ROUND(SUM(price), 2) AS total_monthly_earning
FROM
    order_items AS i
        LEFT JOIN
    orders AS o ON i.order_id = o.order_id
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled')
GROUP BY purchase_month
ORDER BY purchase_month DESC;

SELECT 
    ROUND(AVG(total_monthly_earning), 2) AS avg_monthly_earning
FROM
    (SELECT 
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month,
            SUM(i.price) AS total_monthly_earning
    FROM
        order_items AS i
    LEFT JOIN orders AS o ON i.order_id = o.order_id
    WHERE
        o.order_status NOT IN ('unavailable' , 'canceled')
    GROUP BY purchase_month) AS monthly_totals;

-- 12. Can you work out the average monthly income of Tech sellers?

SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS purchase_month,
    product_category_type,
    ROUND(SUM(price), 2) AS total_monthly_earning
FROM
    order_items AS i
        LEFT JOIN
    orders AS o ON i.order_id = o.order_id
        LEFT JOIN
    products AS p ON i.product_id = p.product_id
        LEFT JOIN
    tech_products AS t ON p.product_category_name = t.product_category_name
WHERE
    product_category_type = 'tech_product'
        AND o.order_status NOT IN ('unavailable' , 'canceled')
GROUP BY purchase_month
ORDER BY purchase_month DESC;

SELECT 
    ROUND(AVG(total_monthly_earning), 2) AS avg_monthly_earning
FROM
    (SELECT 
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS purchase_month,
            product_category_type,
            SUM(i.price) AS total_monthly_earning
    FROM
        order_items AS i
    LEFT JOIN orders AS o ON i.order_id = o.order_id
    LEFT JOIN products AS p ON i.product_id = p.product_id
    LEFT JOIN tech_products AS t ON p.product_category_name = t.product_category_name
    WHERE
        product_category_type = 'tech_product'
            AND o.order_status NOT IN ('unavailable' , 'canceled')
    GROUP BY purchase_month) AS monthly_totals;


/*
Answer business questions

In relation to the delivery time:

*/

-- 13. What’s the average time between the order being placed and the product being delivered?
  
SELECT 
    ROUND(AVG(TIMESTAMPDIFF(DAY,
                order_purchase_timestamp,
                order_delivered_customer_date)),
            2) AS avg_delivery_days
FROM
    orders
WHERE
    order_status = 'delivered'
        AND order_delivered_customer_date IS NOT NULL;
        

  
-- 14. How many orders are delivered on time vs orders delivered with a delay?
--   
SELECT 
    SUM(CASE
        WHEN
            order_status = 'delivered'
                AND order_delivered_customer_date <= order_estimated_delivery_date
        THEN
            1
        ELSE 0
    END) AS on_time_deliveries,
    SUM(CASE
        WHEN
            order_status = 'delivered'
                AND order_delivered_customer_date > order_estimated_delivery_date
        THEN
            1
        ELSE 0
    END) AS delayed_deliveries
FROM
    orders
WHERE
    order_estimated_delivery_date IS NOT NULL
        AND order_delivered_customer_date IS NOT NULL;


SELECT 
    on_time_deliveries,
    delayed_deliveries,
    ROUND(100 * on_time_deliveries / (on_time_deliveries + delayed_deliveries),
            2) AS pct_on_time,
    ROUND(100 * delayed_deliveries / (on_time_deliveries + delayed_deliveries),
            2) AS pct_delayed
FROM
    (SELECT 
        SUM(CASE
                WHEN
                    order_status = 'delivered'
                        AND order_delivered_customer_date <= order_estimated_delivery_date
                THEN
                    1
                ELSE 0
            END) AS on_time_deliveries,
            SUM(CASE
                WHEN
                    order_status = 'delivered'
                        AND order_delivered_customer_date > order_estimated_delivery_date
                THEN
                    1
                ELSE 0
            END) AS delayed_deliveries
    FROM
        orders) AS counts;

-- 15. Is there any pattern for delayed orders, e.g. big products being delayed more often?



WITH item_delays AS (
  SELECT
    p.product_id,
    p.product_length_cm,
    /* bucket length into e.g. small/medium/large */
    CASE
      WHEN p.product_length_cm < 20 THEN 'small'
      WHEN p.product_length_cm BETWEEN 20 AND 50 THEN 'medium'
      ELSE 'large'
    END AS length_bucket,
    CASE
      WHEN o.order_status = 'delivered'
       AND o.order_delivered_customer_date > o.order_estimated_delivery_date
      THEN 1 ELSE 0
    END AS was_delayed
  FROM order_items i
  JOIN orders o ON i.order_id = o.order_id
  JOIN products p ON i.product_id = p.product_id
)
SELECT
  length_bucket,
  COUNT(*)                               AS total_items,
  SUM(was_delayed)                       AS delayed_items,
  ROUND(100 * SUM(was_delayed) / COUNT(*), 2) AS pct_delayed
FROM item_delays
GROUP BY length_bucket
ORDER BY FIELD(length_bucket, 'small','medium','large');



WITH item_delays AS (
  SELECT
    p.product_id,
    p.product_weight_g,
    /* bucket weights into e.g. light/medium/heavy */
    CASE
      WHEN p.product_weight_g < 1000 THEN 'light, < 1000 g'
      WHEN p.product_weight_g BETWEEN 1000 AND 5000 THEN 'medium, between 1000 and 5000 g'
      ELSE 'heavy > 5000 g'
    END AS weight_bucket,
    CASE
      WHEN o.order_status = 'delivered'
       AND o.order_delivered_customer_date > o.order_estimated_delivery_date
      THEN 1 ELSE 0
    END AS was_delayed
  FROM order_items i
  JOIN orders o ON i.order_id = o.order_id
  JOIN products p ON i.product_id = p.product_id
)
SELECT
  weight_bucket,
  COUNT(*)                               AS total_items,
  SUM(was_delayed)                       AS delayed_items,
  ROUND(100 * SUM(was_delayed) / COUNT(*), 2) AS pct_delayed
FROM item_delays
GROUP BY weight_bucket
ORDER BY FIELD(weight_bucket, 'light, < 1000 g','medium, between 1000 and 5000 g','heavy > 5000 g');





