-- Run this manually AFTER the first successful Airflow DAG run.
-- Then trigger the DAG again.

UPDATE public.customers
SET city = 'Moscow'
WHERE customer_id = 1;

-- Add a new transaction AFTER the customer change so that the new SCD2
-- version is actually referenced by a fact row.
INSERT INTO public.transactions (
    transaction_id,
    card_id,
    merchant_id,
    amount,
    currency,
    transaction_type,
    status,
    transaction_time
)
VALUES (
    9001,
    1001,
    3,
    3250.00,
    'RUB',
    'PURCHASE',
    'SUCCESS',
    CURRENT_TIMESTAMP
)
ON CONFLICT (transaction_id)
DO UPDATE SET
    amount = EXCLUDED.amount,
    transaction_time = EXCLUDED.transaction_time;
