-- SCD Type 2 for customer attributes.
-- If first_name, last_name, birth_date or city changes, the old row is closed
-- and a new current version is inserted.

UPDATE dwh.dim_customer d
SET
    valid_to = CURRENT_TIMESTAMP,
    is_current = FALSE
FROM staging.customers s
WHERE d.customer_id = s.customer_id
  AND d.is_current = TRUE
  AND ROW(
        d.first_name,
        d.last_name,
        d.birth_date,
        d.city
      ) IS DISTINCT FROM ROW(
        s.first_name,
        s.last_name,
        s.birth_date,
        s.city
      );

INSERT INTO dwh.dim_customer (
    customer_id,
    first_name,
    last_name,
    birth_date,
    city,
    valid_from,
    valid_to,
    is_current
)
SELECT
    s.customer_id,
    s.first_name,
    s.last_name,
    s.birth_date,
    s.city,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM dwh.dim_customer h
            WHERE h.customer_id = s.customer_id
        )
        THEN CURRENT_TIMESTAMP
        ELSE s.registration_date::TIMESTAMP
    END AS valid_from,
    TIMESTAMP '9999-12-31 23:59:59' AS valid_to,
    TRUE AS is_current
FROM staging.customers s
LEFT JOIN dwh.dim_customer d
    ON d.customer_id = s.customer_id
   AND d.is_current = TRUE
WHERE d.customer_id IS NULL;
