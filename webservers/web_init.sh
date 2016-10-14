#!/bin/sh

# Create env file, which will be read from an app.
ENV_FILE=/opt/micropost/env.sh
mkdir -p $(dirname $${ENV_FILE})
cat << EOF > $${ENV_FILE}
export SPRING_PROFILES_ACTIVE=${env}
export RDS_ENDPOINT=${dbserver_endpoint}
export S3_DEPLOY_BUCKET=${deploy_bucket}
EOF

# Finalize provisioning by using resolved endpoints.
(
cd /opt/provisioning

cat << EOF > inventory
[webservers]
localhost
EOF

le_key=$(cat /etc/le/config | grep user-key | cut -d" " -f3)
ansible-playbook -i inventory -c local --diff -e "deploy_bucket=${deploy_bucket}" -e "nginx_cdn_bucket=${nginx_cdn_bucket}" -e "logentries_account_key=$${le_key}" site.yml
)
