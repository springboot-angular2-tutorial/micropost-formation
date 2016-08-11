#!/bin/sh

# Create env file, which will be read from an app.
ENV_FILE=/opt/micropost/env.sh
mkdir -p $(dirname $${ENV_FILE})
cat << EOF > $${ENV_FILE}
export SPRING_PROFILES_ACTIVE=${env}
export RDS_ENDPOINT=${rds_endpoint}
export REDIS_ENDPOINT=${redis_endpoint}
export S3_DEPLOY_BUCKET=${s3_deploy_bucket}
EOF

# Finalize provisioning by using resolved endpoints.
(
cd /opt/provisioning

cat << EOF > inventory
[webservers]
localhost
EOF

ansible-playbook -i inventory --connection=local --sudo --diff -e "logstash_elasticsearch_host=${logserver_endpoint}" -e "letsencrypt_host=${web_endpoint}" -e "deploy_bucket=${s3_deploy_bucket}" site.yml
)

# Update SSL cert
/usr/local/bin/update_cert.sh
