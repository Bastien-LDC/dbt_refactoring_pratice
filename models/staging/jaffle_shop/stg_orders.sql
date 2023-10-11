WITH orders AS (
    SELECT * FROM {{ source('jaffle_shop', 'orders') }}
),

staged AS (
    SELECT 
        id AS order_id
      , user_id AS customer_id
      , order_date
      , status 
    FROM orders
)
SELECT * FROM staged
{{ limit_data_in_dev('order_date', 10000) }}