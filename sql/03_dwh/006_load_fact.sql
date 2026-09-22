INSERT INTO dwh.fact_transactions (
    transaction_id,
    customer_key,
    card_key,
    merchant_key,
    date_key,
    transaction_timestamp,
    amount,
    transaction_count,
    currency,
    transaction_type,
    status
)
SELECT
    t.transaction_id,
    dc.customer_key,
    dcard.card_key,
    dm.merchant_key,
    dd.date_key,
    t.transaction_time,
    t.amount,
    1,
    t.currency,
    t.transaction_type,
    t.status
FROM staging.transactions t
JOIN staging.cards c
    ON t.card_id = c.card_id
JOIN staging.accounts a
    ON c.account_id = a.account_id
JOIN dwh.dim_customer dc
    ON dc.customer_id = a.customer_id
   AND t.transaction_time >= dc.valid_from
   AND t.transaction_time < dc.valid_to
JOIN dwh.dim_card dcard
    ON dcard.card_id = t.card_id
JOIN dwh.dim_merchant dm
    ON dm.merchant_id = t.merchant_id
JOIN dwh.dim_date dd
    ON dd.full_date = t.transaction_time::DATE
ON CONFLICT (transaction_id)
DO UPDATE SET
    customer_key = EXCLUDED.customer_key,
    card_key = EXCLUDED.card_key,
    merchant_key = EXCLUDED.merchant_key,
    date_key = EXCLUDED.date_key,
    transaction_timestamp = EXCLUDED.transaction_timestamp,
    amount = EXCLUDED.amount,
    transaction_count = EXCLUDED.transaction_count,
    currency = EXCLUDED.currency,
    transaction_type = EXCLUDED.transaction_type,
    status = EXCLUDED.status,
    loaded_at = CURRENT_TIMESTAMP;
