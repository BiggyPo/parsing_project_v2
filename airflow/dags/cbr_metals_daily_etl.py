from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator

default_args = {
    'owner': 'biggy',
    'depends_on_past': False,
    'start_date': datetime(2025, 12, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'cbr_metals_daily_etl',
    default_args=default_args,
    description='Ежедневный ETL пайплайн для данных о драгметаллах ЦБ РФ',
    schedule_interval='0 13 * * *',  # Запуск в 13:00 каждый день
    catchup=False,
    tags=['cbr', 'metals', 'etl', 'dbt'],
) as dag:
    
    start = EmptyOperator(task_id='start')
    
    # Запуск dbt трансформации
    run_dbt = BashOperator(
        task_id='run_dbt_transform',
        bash_command='cd /usr/app && dbt run --profiles-dir .',
    )
    
    # Запуск dbt тестов
    run_dbt_tests = BashOperator(
        task_id='run_dbt_tests',
        bash_command='cd /usr/app && dbt test --profiles-dir .',
    )
    
    end = EmptyOperator(task_id='end')
    
    # Определяем порядок выполнения
    start >> run_dbt >> run_dbt_tests >> end
