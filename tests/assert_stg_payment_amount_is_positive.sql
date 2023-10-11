-- Singular test inside ./test/

-- Refunds have a negative amount, so the total amount should always be >= 0.
-- Therefore return records where this isn't true to make the test fail.
WITH  payments AS (
    SELECT * FROM {{ ref('stg_payments') }}
)

SELECT 
    order_id
  , SUM(amount) as total_amount
FROM payments
GROUP BY 1
HAVING total_amount < 0