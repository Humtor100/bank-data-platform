CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.customers
AS SELECT * FROM public.customers WITH NO DATA;

CREATE TABLE IF NOT EXISTS staging.accounts
AS SELECT * FROM public.accounts WITH NO DATA;

CREATE TABLE IF NOT EXISTS staging.cards
AS SELECT * FROM public.cards WITH NO DATA;

CREATE TABLE IF NOT EXISTS staging.merchants
AS SELECT * FROM public.merchants WITH NO DATA;

CREATE TABLE IF NOT EXISTS staging.transactions
AS SELECT * FROM public.transactions WITH NO DATA;
