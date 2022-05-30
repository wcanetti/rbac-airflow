###### Python script exec ######
airflow_url="https://97c6b87b197f486aacef2612f9f30392-dot-us-central1.composer.googleusercontent.com"
role_name="READ"
dag_list=DAG-A
token=$(echo $(gcloud auth print-access-token))
privileges="read"
python3 airflow_rbac_roles.py -u $airflow_url -r $role_name -t $token -d $dag_list -p $privileges

airflow_url="https://f8db6ec6b9e847b1943c7e6ee63a993b-dot-us-central1.composer.googleusercontent.com"
role_name="READ_EDIT"
dag_list=DAG-B
token=$(echo $(gcloud auth print-access-token))
privileges=("read edit")
python3 airflow_rbac_roles.py -u $airflow_url -r $role_name -t $token -d $dag_list -p $privileges

airflow_url="https://f8db6ec6b9e847b1943c7e6ee63a993b-dot-us-central1.composer.googleusercontent.com"
role_name="READ_EDIT_CREATE"
dag_list=DAG-B
token=$(echo $(gcloud auth print-access-token))
privileges=("read edit create")
python3 airflow_rbac_roles.py -u $airflow_url -r $role_name -t $token -d $dag_list -p $privileges

###### Role management ######

gcloud composer environments run rbac-airflow \
--location us-central1 \
users add-role -- -e Nelson.O.Valenzuela@gmail.com -r Admin

gcloud composer environments run rbac-airflow \
--location us-central1 \
users remove-role -- -e Nelson.O.Valenzuela@gmail.com -r Admin

gcloud composer environments run rbac-airflow \
--location us-central1 \
users add-role -- -e n3lsok@gmail.com -r CONSUMER-A

gcloud composer environments run rbac-airflow \
--location us-central1 \
users add-role -- -e n3lsok@gmail.com -r CONSUMER-B

gcloud composer environments run rbac-airflow \
--location us-central1 \
users add-role -- -e n3lsok@gmail.com -r CONSUMER-C

gcloud composer environments run rbac-airflow \
--location us-central1 \
users remove-role -- -e n3lsok@gmail.com -r CONSUMER-C

gcloud composer environments run rbac-airflow \
--location us-central1 \
roles list


gcloud composer environments run grp-composer-svpc-sbx-2 \
--location us-central1 \
users add-role -- -e c_nfelipeolivavalenz@groupon.com -r Admin
