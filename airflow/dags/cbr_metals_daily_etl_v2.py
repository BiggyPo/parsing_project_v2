from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator

default_args = {
    'owner': 'biggy',
    'depends_on_past': False,
    'start_date': datetime(2025, 12, 20),  # ИЗМЕНЕНО: прошедшая дата
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'cbr_metals_daily_etl_v2',
    default_args=default_args,
    description='Улучшенный ETL пайплайн с поэтапным выполнением DBT',
    schedule_interval='30 7 * * *',  # Запуск в 7:30 UTC (10:30 МСК)
    catchup=False,
    tags=['cbr', 'metals', 'etl', 'dbt', 'production'],
) as dag:
    
    start = EmptyOperator(task_id='start')
    
    # 1. Проверка и трансформация staging слоя
    run_staging = BashOperator(
        task_id='run_dbt_staging',
        bash_command='cd /usr/app && dbt run --models staging.* --profiles-dir .',
    )
    
    # 2. Создание DDS слоя (витрины)
    run_dds = BashOperator(
        task_id='run_dbt_dds',
        bash_command='cd /usr/app && dbt run --models dds.* --profiles-dir .',
    )
    
    # 3. Создание MART слоя (аналитика)
    run_mart = BashOperator(
        task_id='run_dbt_mart',
        bash_command='cd /usr/app && dbt run --models mart.* --profiles-dir .',
    )
    
    # 4. Запуск тестов
    run_tests = BashOperator(
        task_id='run_dbt_tests',
        bash_command='cd /usr/app && dbt test --profiles-dir .',
    )
    
    end = EmptyOperator(task_id='end')
    
    # Определяем порядок выполнения
    start >> run_staging >> run_dds >> run_mart >> run_tests >> end
