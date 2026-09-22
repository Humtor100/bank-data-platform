CREATE TABLE IF NOT EXISTS dwh.fact_transactions (
    fact_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transaction_id BIGINT NOT NULL UNIQUE,
    customer_key BIGINT NOT NULL REFERENCES dwh.dim_customer(customer_key),
    card_key BIGINT NOT NULL REFERENCES dwh.dim_card(card_key),
    merchant_key BIGINT NOT NULL REFERENCES dwh.dim_merchant(merchant_key),
    date_key INTEGER NOT NULL REFERENCES dwh.dim_date(date_key),
    transaction_timestamp TIMESTAMP NOT NULL,
    amount NUMERIC(18,2) NOT NULL,
    transaction_count INTEGER NOT NULL DEFAULT 1,
    currency VARCHAR(3) NOT NULL,
    transaction_type VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_fact_transactions_customer
    ON dwh.fact_transactions(customer_key);

CREATE INDEX IF NOT EXISTS idx_fact_transactions_date
    ON dwh.fact_transactions(date_key);
