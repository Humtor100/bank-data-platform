CREATE SCHEMA IF NOT EXISTS mart;

CREATE TABLE IF NOT EXISTS mart.daily_bank_metrics (
    metric_date DATE PRIMARY KEY,
    transactions_count BIGINT NOT NULL,
    successful_transactions BIGINT NOT NULL,
    declined_transactions BIGINT NOT NULL,
    turnover NUMERIC(18,2) NOT NULL,
    avg_check NUMERIC(18,2) NOT NULL,
    unique_customers BIGINT NOT NULL,
    declined_rate NUMERIC(10,2) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
