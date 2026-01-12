from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator
from airflow.providers.docker.operators.docker import DockerOperator

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
    
    # ЗАДАЧА run_dbt_all: DockerOperator для запуска dbt
    run_dbt_all = DockerOperator(
    task_id='run_dbt_all',
    image='bank_rates_monitoring-dbt',
    container_name='dbt_task_{{ ds_nodash }}',
    api_version='auto',
    auto_remove=True,
    command='bash -c "cd /usr/app && dbt run --profiles-dir . && dbt test --profiles-dir ."',
    docker_url='unix://var/run/docker.sock',
    # Ключевое изменение 1: Используем сеть, в которой находится контейнер Airflow
    network_mode='container:airflow_scheduler',
    # Ключевое изменение 2: Явно отключаем проблемное временное монтирование
    mount_tmp_dir=False,
    # Ключевое изменение 3: Передаем переменные окружения для подключения к БД
    environment={
        # Эти переменные ДОЛЖНЫ совпадать с настройками в вашем dbt/profiles.yml
        'DBT_HOST': 'postgres',  # Имя контейнера с БД
        'DBT_USER': 'your_dbt_user',  # Замените на реальное имя пользователя БД для dbt
        'DBT_PASSWORD': 'your_dbt_password',  # Замените на реальный пароль
        'DBT_PORT': 5432,
        'DBT_DATABASE': 'your_dbt_database'  # Замените на имя БД
    },
    mounts=[
        {
            # Убедитесь, что этот путь В ТОЧНОСТИ совпадает с путем в вашем docker-compose для сервиса dbt
            'Source': '/home/biggypo/bank_rates_monitoring/dbt',
            'Target': '/usr/app',
            'Type': 'bind',
            'ReadOnly': False
        }
    ],
    user='root',
    dag=dag,
)

    end = EmptyOperator(task_id='end')
    
    # Определение последовательности задач
    start >> run_dbt_all >> end
