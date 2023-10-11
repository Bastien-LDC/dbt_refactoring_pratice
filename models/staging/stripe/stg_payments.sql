WITH payments AS (
    SELECT * FROM {{ source('stripe', 'payment') }}
),

staged AS (
    SELECT 
        id AS payment_id
      , orderid AS order_id
      , paymentmethod AS payment_method
      , status
      -- amount is stored in cents, convert it to dollars
      , {{ cents_to_dollars('amount') }} AS amount
      , created AS created_at
    FROM payments
    ORDER BY payment_id
)
SELECT * FROM staged