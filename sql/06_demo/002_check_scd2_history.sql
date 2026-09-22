SELECT
    customer_key,
    customer_id,
    first_name,
    last_name,
    city,
    valid_from,
    valid_to,
    is_current
FROM dwh.dim_customer
WHERE customer_id = 1
ORDER BY valid_from;

SELECT
    f.transaction_id,
    f.transaction_timestamp,
    c.customer_key,
    c.city,
    f.amount
FROM dwh.fact_transactions f
JOIN dwh.dim_customer c
    ON f.customer_key = c.customer_key
WHERE c.customer_id = 1
ORDER BY f.transaction_timestamp;
