from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator

default_args = {
    'owner': 'biggy',
    'depends_on_past': False,
    'start_date': datetime(2025, 12, 20),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=2),
}

with DAG(
    'cbr_metals_daily_etl_final',
    default_args=default_args,
    description='Финальный ETL: NiFi в 7:00 UTC, DBT в 7:30 UTC',
    schedule_interval='30 7 * * *', 
    catchup=False,
    tags=['cbr', 'metals', 'etl', 'dbt', 'production', 'final'],
) as dag:
    
    start = EmptyOperator(task_id='start')
    
    # ИСПРАВЛЕННАЯ задача: правильный параметр bash_command вместо command
    run_dbt_all = BashOperator(
        task_id='run_dbt_all',
        # Команда выполняется через docker exec внутри контейнера Airflow
        bash_command='docker exec -i dbt bash -c "cd /usr/app && dbt run --profiles-dir . && dbt test --profiles-dir ."',
    )
    
    end = EmptyOperator(task_id='end')
    
    start >> run_dbt_all >> end
