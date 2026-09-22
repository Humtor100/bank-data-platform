from __future__ import annotations

from datetime import timedelta

import pendulum

from airflow.sdk import DAG

from airflow.providers.common.sql.operators.sql import (
    SQLExecuteQueryOperator,
    SQLValueCheckOperator,
)


POSTGRES_CONN_ID = "bank_postgres"


default_args = {

    "owner": "bank-data-platform",

    "retries": 2,

    "retry_delay": timedelta(
        minutes=1
    ),
}


with DAG(

    dag_id="bank_dwh_pipeline",

    description=(
        "Bank DWH pipeline: "
        "staging -> dimensions -> SCD2 -> fact -> mart -> quality"
    ),

    start_date=pendulum.datetime(
        2026,
        1,
        1,
        tz="UTC"
    ),

    schedule=None,

    catchup=False,

    max_active_runs=1,

    default_args=default_args,

    template_searchpath=[
        "/opt/airflow/sql"
    ],

    tags=[
        "bank",
        "dwh",
        "pet-project"
    ],

) as dag:


    # =========================================================
    # 1. LOAD STAGING
    # =========================================================

    load_staging = SQLExecuteQueryOperator(

        task_id="load_staging",

        conn_id=POSTGRES_CONN_ID,

        sql="02_staging/002_load_staging.sql",

        autocommit=True,
    )


    # =========================================================
    # 2. LOAD DATE DIMENSION
    # =========================================================

    load_date_dimension = SQLExecuteQueryOperator(

        task_id="load_date_dimension",

        conn_id=POSTGRES_CONN_ID,

        sql="03_dwh/002_load_date_dimension.sql",

        autocommit=True,
    )


    # =========================================================
    # 3. LOAD SCD TYPE 1 DIMENSIONS
    #
    # dim_card
    # dim_merchant
    # =========================================================

    load_scd1_dimensions = SQLExecuteQueryOperator(

        task_id="load_scd1_dimensions",

        conn_id=POSTGRES_CONN_ID,

        sql="03_dwh/003_load_scd1_dimensions.sql",

        autocommit=True,
    )


    # =========================================================
    # 4. CUSTOMER SCD TYPE 2
    # =========================================================

    load_customer_scd2 = SQLExecuteQueryOperator(

        task_id="load_customer_scd2",

        conn_id=POSTGRES_CONN_ID,

        sql="03_dwh/004_load_customer_scd2.sql",

        autocommit=True,
    )


    # =========================================================
    # 5. LOAD FACT
    # =========================================================

    load_fact = SQLExecuteQueryOperator(

        task_id="load_fact",

        conn_id=POSTGRES_CONN_ID,

        sql="03_dwh/006_load_fact.sql",

        autocommit=True,
    )


    # =========================================================
    # 6. LOAD DATA MART
    # =========================================================

    load_daily_mart = SQLExecuteQueryOperator(

        task_id="load_daily_mart",

        conn_id=POSTGRES_CONN_ID,

        sql="04_mart/002_load_daily_mart.sql",

        autocommit=True,
    )


    # =========================================================
    # DATA QUALITY #1
    #
    # staging transactions == fact transactions
    # =========================================================

    check_row_count = SQLValueCheckOperator(

        task_id="check_row_count",

        conn_id=POSTGRES_CONN_ID,

        sql="""

            SELECT ABS(

                (
                    SELECT COUNT(*)
                    FROM staging.transactions
                )

                -

                (
                    SELECT COUNT(*)
                    FROM dwh.fact_transactions
                )

            );

        """,

        pass_value=0,
    )


    # =========================================================
    # DATA QUALITY #2
    #
    # Проверяем сумму успешных операций
    # =========================================================

    check_success_amount = SQLValueCheckOperator(

        task_id="check_success_amount",

        conn_id=POSTGRES_CONN_ID,

        sql="""

            SELECT ABS(

                COALESCE(

                    (
                        SELECT SUM(amount)

                        FROM staging.transactions

                        WHERE status = 'SUCCESS'
                    ),

                    0
                )

                -

                COALESCE(

                    (
                        SELECT SUM(amount)

                        FROM dwh.fact_transactions

                        WHERE status = 'SUCCESS'
                    ),

                    0
                )

            );

        """,

        pass_value=0,
    )


    # =========================================================
    # DATA QUALITY #3
    #
    # Дубликаты transaction_id
    # =========================================================

    check_transaction_duplicates = SQLValueCheckOperator(

        task_id="check_transaction_duplicates",

        conn_id=POSTGRES_CONN_ID,

        sql="""

            SELECT COUNT(*)

            FROM (

                SELECT transaction_id

                FROM dwh.fact_transactions

                GROUP BY transaction_id

                HAVING COUNT(*) > 1

            ) duplicated;

        """,

        pass_value=0,
    )


    # =========================================================
    # DATA QUALITY #4
    #
    # Для одного customer_id должна быть
    # максимум одна current версия.
    # =========================================================

    check_customer_scd2 = SQLValueCheckOperator(

        task_id="check_customer_scd2",

        conn_id=POSTGRES_CONN_ID,

        sql="""

            SELECT COUNT(*)

            FROM (

                SELECT customer_id

                FROM dwh.dim_customer

                WHERE is_current = TRUE

                GROUP BY customer_id

                HAVING COUNT(*) > 1

            ) broken_customers;

        """,

        pass_value=0,
    )


    # =========================================================
    # DAG DEPENDENCIES
    # =========================================================

    load_staging >> load_date_dimension


    load_date_dimension >> [

        load_scd1_dimensions,

        load_customer_scd2,

    ]


    [

        load_scd1_dimensions,

        load_customer_scd2,

    ] >> load_fact


    load_fact >> load_daily_mart


    load_daily_mart >> [

        check_row_count,

        check_success_amount,

        check_transaction_duplicates,

        check_customer_scd2,

    ]