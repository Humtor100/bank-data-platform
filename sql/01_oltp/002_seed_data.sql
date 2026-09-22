INSERT INTO public.customers (
    customer_id, first_name, last_name, birth_date, city, registration_date
)
VALUES
    (1, 'Ivan',   'Petrov',   DATE '1995-05-12', 'Vladivostok',      DATE '2025-01-10'),
    (2, 'Anna',   'Sidorova', DATE '1998-08-21', 'Moscow',           DATE '2025-02-15'),
    (3, 'Alexey', 'Ivanov',   DATE '1992-11-03', 'Kazan',            DATE '2025-03-20'),
    (4, 'Maria',  'Volkova',  DATE '1996-04-14', 'Saint Petersburg', DATE '2025-04-11')
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO public.accounts (
    account_id, customer_id, account_type, currency, balance, opened_at, status
)
VALUES
    (101, 1, 'CHECKING', 'RUB', 150000.00, DATE '2025-01-10', 'ACTIVE'),
    (102, 1, 'SAVINGS',  'RUB', 500000.00, DATE '2025-01-15', 'ACTIVE'),
    (103, 2, 'CHECKING', 'RUB',  80000.00, DATE '2025-02-15', 'ACTIVE'),
    (104, 3, 'CHECKING', 'RUB', 120000.00, DATE '2025-03-20', 'ACTIVE'),
    (105, 4, 'CHECKING', 'RUB', 210000.00, DATE '2025-04-11', 'ACTIVE')
ON CONFLICT (account_id) DO NOTHING;

INSERT INTO public.cards (
    card_id, account_id, card_type, payment_system, status, issued_at, expires_at
)
VALUES
    (1001, 101, 'DEBIT', 'MIR', 'ACTIVE', DATE '2025-01-11', DATE '2030-01-31'),
    (1002, 102, 'DEBIT', 'MIR', 'ACTIVE', DATE '2025-01-16', DATE '2030-01-31'),
    (1003, 103, 'DEBIT', 'MIR', 'ACTIVE', DATE '2025-02-16', DATE '2030-02-28'),
    (1004, 104, 'DEBIT', 'MIR', 'ACTIVE', DATE '2025-03-21', DATE '2030-03-31'),
    (1005, 105, 'DEBIT', 'MIR', 'ACTIVE', DATE '2025-04-12', DATE '2030-04-30')
ON CONFLICT (card_id) DO NOTHING;

INSERT INTO public.merchants (
    merchant_id, merchant_name, merchant_category, city
)
VALUES
    (1, 'Coffee Like',  'CAFE',        'Vladivostok'),
    (2, 'DNS',          'ELECTRONICS', 'Vladivostok'),
    (3, 'Ozon',         'MARKETPLACE', 'Moscow'),
    (4, 'Pyaterochka',  'GROCERY',     'Moscow'),
    (5, 'Yandex Go',    'TRANSPORT',   'Moscow')
ON CONFLICT (merchant_id) DO NOTHING;

INSERT INTO public.transactions (
    transaction_id, card_id, merchant_id, amount, currency,
    transaction_type, status, transaction_time
)
VALUES
    (1,  1001, 1,   450.00, 'RUB', 'PURCHASE', 'SUCCESS',  TIMESTAMP '2026-08-25 09:15:00'),
    (2,  1001, 2, 12000.00, 'RUB', 'PURCHASE', 'SUCCESS',  TIMESTAMP '2026-08-25 14:20:00'),
    (3,  1001, 4,  1850.50, 'RUB', 'PURCHASE', 'SUCCESS',  TIMESTAMP '2026-08-26 18:05:00'),
    (4,  1002, 3,  7300.00, 'RUB', 'PURCHASE', 'SUCCESS',  TIMESTAMP '2026-08-26 19:30:00'),
    (5,  1003, 1,   550.00, 'RUB', 'PURCHASE', 'DECLINED', TIMESTAMP '2026-08-26 10:10:00'),
    (6,  1003, 4,  2400.00, 'RUB', 'PURCHASE', 'SUCCESS',  TIMESTAMP '2026-08-27 12:00:00'),
    (7,  1004, 2, 35000.00, 'RUB', 'PURCHASE', 'SUCCESS',  TIMESTAMP '2026-08-27 15:45:00'),
    (8,  1005, 5,   890.00, 'RUB', 'PURCHASE', 'SUCCESS',  TIMESTAMP '2026-08-28 08:20:00'),
    (9,  1005, 3,  4990.00, 'RUB', 'PURCHASE', 'SUCCESS',  TIMESTAMP '2026-08-28 20:35:00'),
    (10, 1001, 1,   510.00, 'RUB', 'PURCHASE', 'DECLINED', TIMESTAMP '2026-08-29 11:05:00')
ON CONFLICT (transaction_id) DO NOTHING;
