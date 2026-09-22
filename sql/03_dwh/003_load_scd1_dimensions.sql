INSERT INTO dwh.dim_card (
    card_id,
    account_id,
    card_type,
    payment_system,
    status,
    issued_at,
    expires_at
)
SELECT
    card_id,
    account_id,
    card_type,
    payment_system,
    status,
    issued_at,
    expires_at
FROM staging.cards
ON CONFLICT (card_id)
DO UPDATE SET
    account_id = EXCLUDED.account_id,
    card_type = EXCLUDED.card_type,
    payment_system = EXCLUDED.payment_system,
    status = EXCLUDED.status,
    issued_at = EXCLUDED.issued_at,
    expires_at = EXCLUDED.expires_at,
    loaded_at = CURRENT_TIMESTAMP;

INSERT INTO dwh.dim_merchant (
    merchant_id,
    merchant_name,
    merchant_category,
    city
)
SELECT
    merchant_id,
    merchant_name,
    merchant_category,
    city
FROM staging.merchants
ON CONFLICT (merchant_id)
DO UPDATE SET
    merchant_name = EXCLUDED.merchant_name,
    merchant_category = EXCLUDED.merchant_category,
    city = EXCLUDED.city,
    loaded_at = CURRENT_TIMESTAMP;
