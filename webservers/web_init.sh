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

ansible-playbook -i inventory -c local --tags configuration,deploy --diff -e "logstash_elasticsearch_host=${logserver_endpoint}" -e "deploy_bucket=${deploy_bucket}" site.yml
)
