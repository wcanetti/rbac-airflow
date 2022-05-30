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
export PROJECT=<project id>
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
- In the following [folder](https://github.com/wcanetti/rbac-airflow/tree/main/dags) you cam find the 2 DAGS we will be using. Open the Cloud Shell and clone the GitHub repo by executing the following command:

```bash
https://github.com/wcanetti/rbac-airflow.git
```

In order to upload them to the Cloud Composer DAGS folder, please execute the following command. Please first replace the <u>composer-environment-name</u> tag with the Cloud Composer instance name.

```bash
export ENVIRONMENT_NAME=<composer-environment-name>
gcloud composer environments storage dags import \
    --environment ${ENVIRONMENT_NAME} \
    --location ${LOCATION} \
    --source="/home/${USER}/rbac-airflow/DAGs"
```

The Python script in this [folder](https://github.com/wcanetti/rbac-airflow/tree/main/roles-creation-python-script) will allow an administrator to create or update airflow RBAC roles in order to add / restrict permissions to a Cloud Composer (Airflow) user.

As part of the parameters this Python script receives, you need too specify:
- Airflow URL (--airflow-url): the Cloud Composer (Airflow) URL.
- Role name (--role-name): the name of the role being created.
- Access Token (--access-token): the access token used to securely connect to the Cloud Composer instance.
- DAGS (--dags): list of comma separated values with the name of the DAGS you want to apply the specified permissions.
- Priviligies (--privilegies): specify "read" for read permissions, specify "edit" for edit permissions, specify "delete" for delete permissions, specify "create" for create and specify "menu" for menu permissions.

<u>Note</u>: each GCP user is created in Cloud Composer with the "Op" Airflow role by default, which in terms of DAGS, gives you the ability to view, create and delete. In order to prevent this role assignment by default, as part of your IAC code you can include initialization scripts to override this behavior. Run the following command to remove the "Op" Airflow role to a user. Do not forget to update the \<project id\> and the \<user\> tag.

```bash
gcloud composer environments run ${ENVIRONMENT_NAME} --location ${LOCATION} --project ${PROJECT} users remove-role -- -e <user> -r Op
````

## RBAC Python script execution

By executing the command below we will be creating a role called "READ" which will only have Airflow read related permissions associated.

```bash
airflow_url=$(echo $(gcloud composer environments describe ${ENVIRONMENT} --location ${LOCATION} --project ${PROJECT} | grep airflowUri | awk '{ print $2}'))
role_name="Consumers-Group-A"
dag_list=DAG-A
token=$(echo $(gcloud auth print-access-token))
privileges="read"

python3 /home/${USER}/rbac-airflow/roles-creation-python-script/airflow_rbac_roles.py -u $airflow_url -r $role_name -t $token -d $dag_list -p $privileges
```

By executing the command below we will be creating a role called "READ_EDIT_CREATE_DELETE_MENU" which will only have Airflow read related permissions associated.

```bash
airflow_url=$(echo $(gcloud composer environments describe ${ENVIRONMENT} --location ${LOCATION} --project ${PROJECT} | grep airflowUri | awk '{ print $2}'))
role_name="Consumers-Group-B"
dag_list=DAG-B
token=$(echo $(gcloud auth print-access-token))
privileges="read edit create delete menu"

python3 /home/${USER}/rbac-airflow/roles-creation-python-script/airflow_rbac_roles.py -u $airflow_url -r $role_name -t $token -d $dag_list -p $privileges
```

GCLOUD Commands para asociación de Rol a Usuario

Demonstration
- Enter your cloud composer logged in as User A and you will be able to only view DAG A.
    - Imagen
- Enter your cloud composer logged in as User B and you will be able to only view DAG B and you will be able to execute it
    - Imagen

Anexo (Nice-To-Have)
- Initialization script para remoción default del permiso Op