
-- Табличка, в которой будет храниться прогресс загрузки

CREATE TABLE IF NOT EXISTS staging.etl_watermark (
    pipeline_name VARCHAR(100) PRIMARY KEY,
    last_transaction_id BIGINT NOT NULL DEFAULT 0,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM staging.transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;


-- Здесь запрещаем повторную вставку одного transaction_id

CREATE UNIQUE INDEX IF NOT EXISTS
    ux_staging_transactions_id
ON staging.transactions(transaction_id);


-- Тут инициализируем watermark на основе уже загруженных данных

INSERT INTO staging.etl_watermark (
    pipeline_name,
    last_transaction_id
)
VALUES (
    'transactions',
    COALESCE(
        (SELECT MAX(transaction_id)
         FROM staging.transactions),
        0
    )
)
ON CONFLICT (pipeline_name) DO NOTHING;


SELECT *
FROM staging.etl_watermark;