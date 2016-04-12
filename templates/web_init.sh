#!/bin/sh

cd /opt/provisioning

cat << EOF > inventory
[web]
localhost
EOF

ansible-playbook -i inventory --connection=local --sudo --diff \
  -e "logstash_elasticsearch_host=${logserver_endpoint}" \
  -e "letsencrypt_host=${web_endpoint}" \
  site.yml

/usr/local/bin/update_cert.sh >/var/log/update_cert 2>&1
