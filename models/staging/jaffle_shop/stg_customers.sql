WITH customers AS (
    SELECT * FROM {{ source('jaffle_shop', 'customers') }}
),

staged AS (
    SELECT 
        id AS customer_id
      , first_name
      , last_name
    FROM customers
)
SELECT * FROM staged
