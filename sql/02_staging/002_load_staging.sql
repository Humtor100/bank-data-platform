TRUNCATE TABLE
    staging.transactions,
    staging.cards,
    staging.accounts,
    staging.merchants,
    staging.customers;

INSERT INTO staging.customers
SELECT * FROM public.customers;

INSERT INTO staging.accounts
SELECT * FROM public.accounts;

INSERT INTO staging.cards
SELECT * FROM public.cards;

INSERT INTO staging.merchants
SELECT * FROM public.merchants;

INSERT INTO staging.transactions
SELECT * FROM public.transactions;
