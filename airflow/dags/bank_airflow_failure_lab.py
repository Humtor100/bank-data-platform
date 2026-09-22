# Этот ДАГ не для боя, только для эксперимента

from datetime import timedelta

import pendulum

from airflow.sdk import DAG

from airflow.providers.common.sql.operators.sql import (
    SQLValueCheckOperator,
)


# Этот параметр нужен для тестирования. Смотрем в airflow чтобы почекать ошибки итд
SIMULATE_FAILURE = False

POSTGRES_CONN_ID = "bank_postgres"


with DAG(
    dag_id="bank_airflow_failure_lab",
    description="Training: task failure and retries",
    start_date=pendulum.datetime(2026, 9, 1, tz="UTC"),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    tags=["bank", "training"],
) as dag:

    # Задача 1: проверяем соединение с PostgreSQL
    check_connection = SQLValueCheckOperator(
        task_id="check_connection",
        conn_id=POSTGRES_CONN_ID,
        sql="SELECT 1;",
        pass_value=1,
    )

    # Задача 2: намеренно создаём ошибку
    check_transaction_count = SQLValueCheckOperator(
        task_id="check_transaction_count",
        conn_id=POSTGRES_CONN_ID,

        sql="SELECT 1;",

        # True: ожидаем 0, хотя SQL вернёт 1.
        # False: ожидаем 1, проверка пройдёт.
        pass_value=0 if SIMULATE_FAILURE else 1,

        retries=2,
        retry_delay=timedelta(seconds=20),
    )

    check_connection >> check_transaction_count