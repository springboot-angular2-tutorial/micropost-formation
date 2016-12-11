#!/bin/sh

# Install New Relic
rpm -Uvh https://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm
yum install -y newrelic-sysmond
nrsysmond-config --set license_key=${newrelic_license_key}
usermod -a -G docker newrelic
/etc/init.d/newrelic-sysmond start

# Register ecs cluster
echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config
