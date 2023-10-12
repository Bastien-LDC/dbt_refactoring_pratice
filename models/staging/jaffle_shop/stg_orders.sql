WITH orders AS (
    SELECT * FROM {{ source('jaffle_shop', 'orders') }}
),

staged AS (
    SELECT 
        id AS order_id
      , user_id AS customer_id
      , order_date
      , status 

      , CASE
            WHEN status NOT IN ('returned', 'return_pending') 
            THEN order_date
        END AS valid_order_date

    FROM orders
)
SELECT * FROM staged
{{ limit_data_in_dev('order_date', 10000) }}