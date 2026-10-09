
-- ==========================================================
-- BANK DATA PLATFORM
-- INCREMENTAL FACT LOADING
--
-- staging.transactions -> dwh.fact_transactions
--
-- Весь файл выполняется одной транзакцией.
-- В Airflow требуется autocommit=False.
-- ==========================================================


-- 1. Не допускаем одновременную загрузку fact
--    другими процессами, использующими этот lock.

SELECT pg_advisory_xact_lock(9212027);


-- ==========================================================
-- 2. Формируем пакет новых транзакций.
--
-- Берём только transaction_id больше собственного
-- watermark fact_transactions.
-- ==========================================================

CREATE TEMP TABLE fact_batch
ON COMMIT DROP

AS

SELECT
    t.transaction_id,

    dc.customer_key,
    dcard.card_key,
    dm.merchant_key,
    dd.date_key,

    t.transaction_time AS transaction_timestamp,

    t.amount,

    1::INTEGER AS transaction_count,

    t.currency,
    t.transaction_type,
    t.status

FROM staging.transactions t


-- Восстанавливаем связь:
-- transaction -> card -> account -> customer.

JOIN staging.cards c
    ON t.card_id = c.card_id

JOIN staging.accounts a
    ON c.account_id = a.account_id


-- Ищем историческую версию клиента,
-- актуальную в день транзакции.

JOIN dwh.dim_customer dc
    ON dc.customer_id = a.customer_id

    AND t.transaction_time::DATE
        BETWEEN dc.valid_from AND dc.valid_to


JOIN dwh.dim_card dcard
    ON dcard.card_id = t.card_id


JOIN dwh.dim_merchant dm
    ON dm.merchant_id = t.merchant_id


JOIN dwh.dim_date dd
    ON dd.full_date = t.transaction_time::DATE


WHERE t.transaction_id > (

    SELECT w.last_transaction_id

    FROM staging.etl_watermark w

    WHERE w.pipeline_name = 'fact_transactions'
);


-- ==========================================================
-- 3. Проверка: не потеряли ли строки при JOIN?
--
-- Если source содержит 5 новых строк,
-- fact_batch тоже должен содержать ровно 5.
-- ==========================================================

DO $$
DECLARE
    source_count BIGINT;
    batch_count BIGINT;

BEGIN

    SELECT COUNT(*)
    INTO source_count

    FROM staging.transactions t

    WHERE t.transaction_id > (

        SELECT last_transaction_id

        FROM staging.etl_watermark

        WHERE pipeline_name = 'fact_transactions'
    );


    SELECT COUNT(*)
    INTO batch_count

    FROM fact_batch;


    IF source_count <> batch_count THEN

        RAISE EXCEPTION
            'Fact batch mismatch: source=%, resolved=%',
            source_count,
            batch_count;

    END IF;


    -- Заодно проверяем, не дал ли JOIN несколько
    -- подходящих версий одной транзакции.

    IF EXISTS (

        SELECT 1
        FROM fact_batch

        GROUP BY transaction_id

        HAVING COUNT(*) <> 1

    ) THEN

        RAISE EXCEPTION
            'Duplicate dimension mapping in fact_batch';

    END IF;

END $$;


-- ==========================================================
-- 4. Загружаем новые строки в fact.
-- ==========================================================

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

FROM fact_batch

ON CONFLICT (transaction_id) DO NOTHING;


-- ==========================================================
-- 5. Проверяем, что все ID пакета есть в fact.
-- ==========================================================

DO $$
DECLARE
    batch_count BIGINT;
    fact_count BIGINT;

BEGIN

    SELECT COUNT(*)
    INTO batch_count
    FROM fact_batch;


    SELECT COUNT(*)
    INTO fact_count

    FROM fact_batch b

    JOIN dwh.fact_transactions f
        ON f.transaction_id = b.transaction_id;


    IF batch_count <> fact_count THEN

        RAISE EXCEPTION
            'Fact insert incomplete: batch=%, fact=%',
            batch_count,
            fact_count;

    END IF;

END $$;


-- ==========================================================
-- 6. Обновляем watermark только после загрузки и проверок.
-- ==========================================================

UPDATE staging.etl_watermark w

SET
    last_transaction_id = GREATEST(

        w.last_transaction_id,

        COALESCE(
            (SELECT MAX(transaction_id) FROM fact_batch),
            w.last_transaction_id
        )

    ),

    updated_at = CURRENT_TIMESTAMP

WHERE w.pipeline_name = 'fact_transactions';
