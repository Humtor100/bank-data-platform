CREATE SCHEMA IF NOT EXISTS dwh;

CREATE TABLE IF NOT EXISTS dwh.dim_customer (
    customer_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    city VARCHAR(100) NOT NULL,
    valid_from TIMESTAMP NOT NULL,
    valid_to TIMESTAMP NOT NULL,
    is_current BOOLEAN NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_dim_customer_current
    ON dwh.dim_customer(customer_id)
    WHERE is_current = TRUE;

CREATE INDEX IF NOT EXISTS idx_dim_customer_history
    ON dwh.dim_customer(customer_id, valid_from, valid_to);

CREATE TABLE IF NOT EXISTS dwh.dim_card (
    card_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    card_id BIGINT NOT NULL UNIQUE,
    account_id BIGINT NOT NULL,
    card_type VARCHAR(30) NOT NULL,
    payment_system VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL,
    issued_at DATE NOT NULL,
    expires_at DATE NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dwh.dim_merchant (
    merchant_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    merchant_id BIGINT NOT NULL UNIQUE,
    merchant_name VARCHAR(150) NOT NULL,
    merchant_category VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dwh.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day_of_month INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL,
    is_weekend BOOLEAN NOT NULL
);
