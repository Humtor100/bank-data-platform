INSERT INTO dwh.dim_date (
    date_key,
    full_date,
    year,
    quarter,
    month,
    month_name,
    day_of_month,
    day_of_week,
    is_weekend
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER,
    d::DATE,
    EXTRACT(YEAR FROM d)::INTEGER,
    EXTRACT(QUARTER FROM d)::INTEGER,
    EXTRACT(MONTH FROM d)::INTEGER,
    TRIM(TO_CHAR(d, 'Month')),
    EXTRACT(DAY FROM d)::INTEGER,
    EXTRACT(ISODOW FROM d)::INTEGER,
    EXTRACT(ISODOW FROM d)::INTEGER IN (6, 7)
FROM generate_series(
    TIMESTAMP '2025-01-01 00:00:00',
    TIMESTAMP '2030-12-31 00:00:00',
    INTERVAL '1 day'
) AS d
ON CONFLICT (date_key) DO NOTHING;
