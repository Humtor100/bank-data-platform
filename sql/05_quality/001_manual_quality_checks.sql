-- 1. staging and fact row count difference must be 0.
SELECT ABS(
    (SELECT COUNT(*) FROM staging.transactions)
    -
    (SELECT COUNT(*) FROM dwh.fact_transactions)
) AS row_count_difference;

-- 2. Successful amount difference must be 0.
SELECT ABS(
    COALESCE((
        SELECT SUM(amount)
        FROM staging.transactions
        WHERE status = 'SUCCESS'
    ), 0)
    -
    COALESCE((
        SELECT SUM(amount)
        FROM dwh.fact_transactions
        WHERE status = 'SUCCESS'
    ), 0)
) AS successful_amount_difference;

-- 3. No duplicate transaction IDs.
SELECT transaction_id, COUNT(*)
FROM dwh.fact_transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- 4. Only one current customer row per business key.
SELECT customer_id, COUNT(*)
FROM dwh.dim_customer
WHERE is_current = TRUE
GROUP BY customer_id
HAVING COUNT(*) > 1;
