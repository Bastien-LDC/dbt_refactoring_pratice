WITH 

-- Import CTEs
customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

paid_orders AS (
    SELECT * FROM {{ ref('int_orders') }}
),

-- Logical CTEs
-- ... --

-- Final CTE
final AS (

    SELECT
        paid_orders.order_id
      , paid_orders.customer_id
      , paid_orders.order_placed_at
      , paid_orders.order_status
      , paid_orders.total_amount_paid
      , paid_orders.payment_finalized_date
      , customers.first_name AS customer_first_name
      , customers.last_name AS customer_last_name

      , ROW_NUMBER() OVER (ORDER BY paid_orders.order_id) AS transaction_seq
        
      , ROW_NUMBER() OVER (PARTITION BY paid_orders.customer_id ORDER BY paid_orders.order_id) AS customer_sales_seq

        -- New vs Returning Customer
      , CASE 
            WHEN (
            RANK() OVER (
                PARTITION BY paid_orders.customer_id
                ORDER BY paid_orders.order_placed_at, paid_orders.order_id
            ) = 1
            ) THEN 'new'
        ELSE 'return' 
        END AS nvsr

        -- Customer Lifetime Value
      , SUM(total_amount_paid) OVER (
            PARTITION BY paid_orders.customer_id
            ORDER BY paid_orders.order_placed_at
        ) AS customer_lifetime_value
        
        -- first day of sale
      , FIRST_VALUE(paid_orders.order_placed_at) OVER (
            PARTITION BY paid_orders.customer_id
            ORDER BY paid_orders.order_placed_at
        ) AS fdos

    FROM paid_orders 
    LEFT JOIN customers 
    ON paid_orders.customer_id = customers.customer_id
)
-- Simple SELECT statement

SELECT * FROM final
ORDER BY order_id
