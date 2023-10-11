WITH 

-- Import CTEs
customers AS (
    SELECT * FROM {{ source('jaffle_shop', 'customers') }}
),

orders AS (
    SELECT * FROM {{ source('jaffle_shop', 'orders') }}
),

payments AS (
    SELECT * FROM {{ source('stripe', 'payment') }}
),

-- Logical CTEs
completed_payments AS (
    SELECT 
        orderid AS order_id 
      , MAX(created) AS payment_finalized_date 
      , SUM(amount) / 100.0 AS total_amount_paid
    FROM payments
    WHERE status <> 'fail'
    GROUP BY 1
),

-- Final CTE

-- Simple SELECT statement


paid_orders AS (

    SELECT 
        orders.id AS order_id,
        orders.user_id	AS customer_id,
        orders.order_date AS order_placed_at,
        orders.status AS order_status,
        p.total_amount_paid,
        p.payment_finalized_date,
        C.first_name AS customer_first_name,
        C.last_name AS customer_last_name
    
    FROM orders 

    LEFT JOIN completed_payments AS p 
    ON orders.id = p.order_id

    LEFT JOIN customers AS C 
    ON orders.user_id = C.id
),

customer_orders AS (
    SELECT 
        C.id AS customer_id
      , MIN(order_date) AS first_order_date
      , MAX(order_date) AS most_recent_order_date
      , COUNT(orders.id) AS number_of_orders

    FROM customers C 

    LEFT JOIN orders AS Orders
    ON orders.user_id = C.id 
    GROUP BY 1
)

SELECT
    p.*,
    ROW_NUMBER() OVER (ORDER BY p.order_id) AS transaction_seq,
    
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY p.order_id) AS customer_sales_seq,

    CASE 
        WHEN c.first_order_date = p.order_placed_at
        THEN 'new'
        ELSE 'return' 
    END AS nvsr,

    x.clv_bad AS customer_lifetime_value,
    c.first_order_date AS fdos

FROM paid_orders p

LEFT JOIN 
    customer_orders AS c 
USING (customer_id)

LEFT OUTER JOIN (
    SELECT
        p.order_id,
        SUM(t2.total_amount_paid) AS clv_bad

    FROM paid_orders AS p

    LEFT JOIN 
        paid_orders AS t2 
    ON p.customer_id = t2.customer_id 
    AND p.order_id >= t2.order_id

    GROUP BY 1
    ORDER BY p.order_id
) x 

ON x.order_id = p.order_id

ORDER BY order_id