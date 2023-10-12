WITH

orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

payments AS (
    SELECT * FROM {{ ref('stg_payments') }}
),

completed_payments AS (
    SELECT 
        order_id 
      , MAX(created_at) AS payment_finalized_date 
      , SUM(amount) AS total_amount_paid
    FROM payments
    WHERE status <> 'fail'
    GROUP BY 1
),

paid_orders AS (

    SELECT 
        orders.order_id
      , orders.customer_id
      , orders.order_date AS order_placed_at
      , orders.status AS order_status
      , COALESCE(completed_payments.total_amount_paid, 0) AS total_amount_paid
      , completed_payments.payment_finalized_date
    
    FROM orders 
    LEFT JOIN completed_payments USING (order_id)
)

SELECT * FROM paid_orders