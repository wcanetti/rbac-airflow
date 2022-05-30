# AIRFLOW RBAC permissions
This POC will allow Cloud Composer administrators to restrict access permissions at a lower level (not just at the service level by leveraging Cloud IAM, but also at the DAG level) within the AIRFLOW environment by using AIRFLOW RBAC module.

## Cloud Composer Environment Creation
First ensure that the Cloud Composer API is enabled. You can check that by going to the "API & Services" menu and then to the "Enabled API and Services" submenu. If it's not enabled, you can quickly do it in the console by looking for the "Cloud Composer API" service and clicking on the "Enable API" button or through the cloud shell with the following command:

```bash
gcloud services enable composer.googleapis.com
```

In case you have a Composer instance already created, skip this step, if not, in order to create one, you can quickly do so by executing the following commands.

<u>Note</u>: because Cloud Composer 2 uses Workload Identity, the service account of your environment must have bindings to the Kubernetes service account that runs your environment's cluster. As part of the commands exeecution below we add the role roles/composer.ServiceAgentV2Ext to the default Cloud Composer service account.

```bash

export LOCATION=us-central1
export IMAGE_VERSION=composer-2.0.14-airflow-2.2.3
export ENVIRONMENT_SIZE=small

gcloud projects add-iam-policy-binding fresh-sequence-351813 \
    --member serviceAccount:service-962595729151@cloudcomposer-accounts.iam.gserviceaccount.com \
    --role roles/composer.ServiceAgentV2Ext

gcloud composer environments create env-1 --location=${LOCATION} --image-version=${IMAGE_VERSION} --environment-size=${ENVIRONMENT_SIZE}
```

## POC Scenario Explanation

Two DAGS will be used in this POC:
- <b><u>DAG A</u></b>: prints a "Hello World! This is DAG-A"
- <b><u>DAG-B</u></b>: prints a "Hello World! This is DAG-B"

We will be creating two <u>roles</u>:
- <b><u>Consumers-Group-A</u></b>: which can just <b>view</b> DAG-A.
- <b><u>Consumers-Group-B</u></b>: which can <b>view</b> DAG-B and also <b>execute</b> it.

After having created the two DAGS and ROLES, we will be assigning these ROLES to different users to see the security restrictions applied at the DAG level in action.

## DAGS import to Cloud Composer
- In the following [folder](https://url) you cam find the 2 DAGS we will be using. In order to upload them to the Cloud Composer DAGS folder, please execute the following command:

```bash
gcloud composer environments storage dags import \
    --environment ENVIRONMENT_NAME \
    --location ${LOCATION} \
    --source="LOCAL_FILE_TO_UPLOAD"
```

Python Script y explicación de los parámetros de entrada

Ejecución de Python Script
- Acceso a cloud shell
- Remoción de rol Op (por default)
- Creación de los roles y sus permisos asociados y vinculación con DAG

GCLOUD Commands para asociación de Rol a Usuario

Demonstration
- Enter your cloud composer logged in as User A and you will be able to only view DAG A.
    - Imagen
- Enter your cloud composer logged in as User B and you will be able to only view DAG B and you will be able to execute it
    - Imagen

Anexo (Nice-To-Have)
- Initialization script para remoción default del permiso Op