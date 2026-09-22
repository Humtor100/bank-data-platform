TRUNCATE TABLE mart.daily_bank_metrics;

INSERT INTO mart.daily_bank_metrics (
    metric_date,
    transactions_count,
    successful_transactions,
    declined_transactions,
    turnover,
    avg_check,
    unique_customers,
    declined_rate,
    loaded_at
)
SELECT
    d.full_date,
    COUNT(*) AS transactions_count,
    COUNT(*) FILTER (WHERE f.status = 'SUCCESS') AS successful_transactions,
    COUNT(*) FILTER (WHERE f.status = 'DECLINED') AS declined_transactions,
    COALESCE(
        SUM(f.amount) FILTER (WHERE f.status = 'SUCCESS'),
        0
    )::NUMERIC(18,2) AS turnover,
    COALESCE(
        AVG(f.amount) FILTER (WHERE f.status = 'SUCCESS'),
        0
    )::NUMERIC(18,2) AS avg_check,
    COUNT(DISTINCT f.customer_key) AS unique_customers,
    COALESCE(
        ROUND(
            100.0 * COUNT(*) FILTER (WHERE f.status = 'DECLINED')
            / NULLIF(COUNT(*), 0),
            2
        ),
        0
    )::NUMERIC(10,2) AS declined_rate,
    CURRENT_TIMESTAMP
FROM dwh.fact_transactions f
JOIN dwh.dim_date d
    ON f.date_key = d.date_key
GROUP BY d.full_date
ORDER BY d.full_date;
