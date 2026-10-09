
-- =====================================================
-- BANK DATA PLATFORM
-- STAGING LOAD
--
-- Dimensions: FULL LOAD
-- Transactions: INCREMENTAL LOAD
-- =====================================================

BEGIN;


-- =====================================================
-- 1. Исключаем одновременную загрузку этого pipeline.
-- =====================================================

SELECT pg_advisory_xact_lock(9212026);


-- =====================================================
-- 2. FULL LOAD: customers, accounts, cards, merchants
-- =====================================================

TRUNCATE TABLE
    staging.customers,
    staging.accounts,
    staging.cards,
    staging.merchants;


INSERT INTO staging.customers
SELECT *
FROM public.customers;


INSERT INTO staging.accounts
SELECT *
FROM public.accounts;


INSERT INTO staging.cards
SELECT *
FROM public.cards;


INSERT INTO staging.merchants
SELECT *
FROM public.merchants;


-- =====================================================
-- 3. INCREMENTAL LOAD: transactions
--
-- НЕ очищаем staging.transactions!
-- Копируем только ID больше watermark.
-- =====================================================

WITH copied_rows AS (

    INSERT INTO staging.transactions

    SELECT t.*

    FROM public.transactions t

    CROSS JOIN staging.etl_watermark w

    WHERE w.pipeline_name = 'transactions'

      AND t.transaction_id > w.last_transaction_id

    ON CONFLICT (transaction_id) DO NOTHING

    RETURNING transaction_id
)

-- =====================================================
-- 4. Обновляем watermark.
--
-- Берём максимальный ID из реально вставленных строк.
-- Если новых строк нет, сохраняем прежнее значение.
-- =====================================================

UPDATE staging.etl_watermark w

SET
    last_transaction_id = GREATEST(
        w.last_transaction_id,
        COALESCE(
            (SELECT MAX(transaction_id) FROM copied_rows),
            w.last_transaction_id
        )
    ),

    updated_at = CURRENT_TIMESTAMP

WHERE w.pipeline_name = 'transactions';


-- =====================================================
-- 5. Фиксируем изменения.
-- =====================================================

COMMIT;