WITH 

-- Import CTEs
customers AS(
    SELECT * FROM {{ source('jaffle_shop', 'customers') }}
),

orders AS(
    SELECT * FROM {{ source('jaffle_shop', 'orders') }}
),

payments AS(
    SELECT * FROM {{ source('stripe', 'payment') }}
),

-- Logical CTEs

-- Final CTE

-- Simple SELECT statement


paid_orders AS (

    SELECT 
        orders.ID AS order_id,
        orders.USER_ID	AS customer_id,
        orders.ORDER_DATE AS order_placed_at,
        orders.STATUS AS order_status,
        p.total_amount_paid,
        p.payment_finalized_date,
        C.FIRST_NAME AS customer_first_name,
        C.LAST_NAME AS customer_last_name
    
    FROM orders 

    LEFT JOIN (
        SELECT 
            ORDERID AS order_id, 
            max(CREATED) AS payment_finalized_date, 
            sum(AMOUNT) / 100.0 AS total_amount_paid
        FROM payments
        WHERE STATUS <> 'fail'
        GROUP BY 1) p 
        ON orders.ID = p.order_id

    LEFT JOIN customers C ON orders.USER_ID = C.ID
),

customer_orders AS (
    SELECT 
        C.ID AS customer_id
      , min(ORDER_DATE) AS first_order_date
      , max(ORDER_DATE) AS most_recent_order_date
      , count(ORDERS.ID) AS number_of_orders

    FROM customers C 

    LEFT JOIN orders AS Orders
    ON orders.USER_ID = C.ID 
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
        sum(t2.total_amount_paid) AS clv_bad

    FROM paid_orders p

    LEFT JOIN 
        paid_orders t2 
    ON p.customer_id = t2.customer_id 
    AND p.order_id >= t2.order_id

    GROUP BY 1
    ORDER BY p.order_id
) x 

ON x.order_id = p.order_id

ORDER BY order_id