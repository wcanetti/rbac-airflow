from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta

with DAG(dag_id='DAG-A', 
        schedule_interval=None, 
        start_date=datetime(2022, 5, 23),
        catchup=False
) as dag:

    # Task 1
    dummy_task = DummyOperator(task_id='dummy_task')
    # Task 2
    bash_task = BashOperator(task_id='bash_task', bash_command="echo 'Hello, this is DAG-A'")

dummy_task >> bash_task