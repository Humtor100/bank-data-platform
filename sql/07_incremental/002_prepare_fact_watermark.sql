
-- Регистрируем независимый pipeline загрузки fact.

INSERT INTO staging.etl_watermark (
    pipeline_name,
    last_transaction_id
)
VALUES (
    'fact_transactions',

    COALESCE(
        (
            SELECT MAX(transaction_id)
            FROM dwh.fact_transactions
        ),
        0
    )
)

ON CONFLICT (pipeline_name) DO NOTHING;


-- Проверяем оба watermark.

SELECT
    pipeline_name,
    last_transaction_id,
    updated_at

FROM staging.etl_watermark

ORDER BY pipeline_name;
