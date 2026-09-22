CREATE TABLE IF NOT EXISTS public.customers (
    customer_id BIGINT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    city VARCHAR(100) NOT NULL,
    registration_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.accounts (
    account_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES public.customers(customer_id),
    account_type VARCHAR(30) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    balance NUMERIC(18,2) NOT NULL DEFAULT 0,
    opened_at DATE NOT NULL,
    status VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.cards (
    card_id BIGINT PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES public.accounts(account_id),
    card_type VARCHAR(30) NOT NULL,
    payment_system VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL,
    issued_at DATE NOT NULL,
    expires_at DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.merchants (
    merchant_id BIGINT PRIMARY KEY,
    merchant_name VARCHAR(150) NOT NULL,
    merchant_category VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.transactions (
    transaction_id BIGINT PRIMARY KEY,
    card_id BIGINT NOT NULL REFERENCES public.cards(card_id),
    merchant_id BIGINT NOT NULL REFERENCES public.merchants(merchant_id),
    amount NUMERIC(18,2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    transaction_type VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL,
    transaction_time TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_transactions_card_id
    ON public.transactions(card_id);

CREATE INDEX IF NOT EXISTS idx_transactions_time
    ON public.transactions(transaction_time);

CREATE INDEX IF NOT EXISTS idx_transactions_card_time
    ON public.transactions(card_id, transaction_time);
