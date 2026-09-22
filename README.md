# Bank Data Platform — clean checkpoint

Учебный Data Engineering проект в банковской предметной области.

Текущая точка проекта:

- PostgreSQL OLTP;
- staging layer;
- dimensional DWH;
- Star Schema;
- SCD Type 2 для клиента;
- fact_transactions;
- daily data mart;
- Data Quality / reconciliation;
- Apache Airflow DAG.

## 1. Архитектура

```text
public (OLTP)
    |
    v
staging
    |
    +--> dim_card / dim_merchant (SCD1)
    |
    +--> dim_customer (SCD2)
    |
    +--> dim_date
            |
            v
      fact_transactions
            |
            v
     daily_bank_metrics
            |
            v
      Data Quality checks
```

Airflow запускает загрузки в нужном порядке.

## 2. Контейнеры

Проект поднимает три постоянных компонента и один init-service:

- `bank-db` — PostgreSQL с учебной банковской БД;
- `airflow-meta` — отдельная metadata-БД Airflow;
- `airflow` — Airflow 3.3.1 в standalone-режиме;
- `bank-init` — одноразово создает таблицы и sample data.

Важно: metadata Airflow и банковские данные находятся в РАЗНЫХ PostgreSQL базах.

## 3. Первый чистый запуск

Требуется Docker Desktop с Docker Compose v2.

В PowerShell из корня проекта:

```powershell
docker compose down -v --remove-orphans
docker compose up --build -d
```

Или:

```powershell
./scripts/reset_project.ps1
```

Проверить:

```powershell
docker compose ps
```

Посмотреть логи Airflow:

```powershell
docker compose logs -f airflow
```

## 4. Airflow UI

Открыть:

```text
http://localhost:8080
```

В этом локальном учебном проекте включен `SIMPLE_AUTH_MANAGER_ALL_ADMINS`, поэтому отдельная настройка пользователя не нужна.

Найди DAG:

```text
bank_dwh_pipeline
```

Нажми **Trigger DAG**.

Ожидаемый граф:

```text
load_staging
     |
     v
load_date_dimension
     |
     +--------------------+
     v                    v
load_scd1_dimensions   load_customer_scd2
     |                    |
     +----------+---------+
                v
            load_fact
                |
                v
        load_daily_mart
                |
       +--------+--------+----------------+
       v        v        v                v
  row_count   amount   duplicates      SCD2 check
```

## 5. Подключение PyCharm к bank_db

Data Source -> PostgreSQL:

```text
Host: localhost
Port: 5433
Database: bank_db
User: bank_user
Password: bank_password
```

Проверка:

```sql
SELECT current_database();
```

Должно вернуть:

```text
bank_db
```

## 6. Что делает DAG

### load_staging

Full Load из `public` в `staging`.

### load_date_dimension

Создает календарное измерение 2025-2030.

### load_scd1_dimensions

Upsert `dim_card` и `dim_merchant`.

### load_customer_scd2

Если изменились имя, фамилия, дата рождения или город клиента:

1. текущая версия получает `is_current = false`;
2. `valid_to` закрывается текущим timestamp;
3. вставляется новая версия с новым surrogate key.

### load_fact

Одна строка = одна транзакция.

Версия клиента подбирается по времени события:

```sql
t.transaction_time >= dc.valid_from
AND t.transaction_time < dc.valid_to
```

### load_daily_mart

Строит дневные показатели:

- количество операций;
- success / declined;
- turnover;
- average check;
- unique customers;
- decline rate.

### Data Quality

DAG проверяет:

- staging row count = fact row count;
- сумма SUCCESS staging = сумма SUCCESS fact;
- transaction_id не дублируется;
- у клиента не больше одной current SCD2 версии.

## 7. Проверка SCD Type 2

Сначала один раз успешно запусти DAG.

После этого выполни вручную:

```text
sql/06_demo/001_scd2_demo_change.sql
```

Скрипт:

- меняет город `customer_id = 1`;
- создает новую транзакцию после изменения.

После этого снова Trigger DAG.

Затем выполни:

```text
sql/06_demo/002_check_scd2_history.sql
```

В `dim_customer` должны быть две версии customer 1:

```text
old: Vladivostok / is_current=false
new: Moscow      / is_current=true
```

Старые транзакции должны ссылаться на старый `customer_key`, новая транзакция — на новый.

## 8. Полный сброс

Если Docker снова запутался:

```powershell
docker compose down -v --remove-orphans
docker compose up --build -d
```

`-v` удаляет volumes проекта, поэтому БД создается заново из seed data.

Если у тебя старые контейнеры ИЗ ДРУГОГО compose-проекта занимают 5433 или 8080, найди их:

```powershell
docker ps -a
```

и либо останови старый проект, либо измени `.env`:

```text
BANK_DB_PORT=5434
AIRFLOW_PORT=8081
```

## 9. Важные термины к собеседованию

- OLTP vs OLAP;
- staging;
- fact / dimension;
- grain;
- Star Schema;
- natural key / surrogate key;
- SCD Type 1 / Type 2;
- full load / incremental load;
- idempotency;
- reconciliation;
- Data Quality;
- DAG / task / dependency / retry;
- orchestration.

## 10. Текущая граница проекта

На этом checkpoint мы ОСТАНАВЛИВАЕМСЯ на Airflow + SCD2.

Следующие темы — incremental load, Kafka, PySpark и Iceberg — намеренно пока не добавлены, чтобы не смешивать этапы обучения.
