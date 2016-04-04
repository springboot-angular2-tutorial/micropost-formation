output "ami_web" {
  value = "${aws_launch_configuration.web.image_id}"
}

output "logserver_endpoint" {
  value = "${aws_elasticsearch_domain.logserver.endpoint}"
}

output "rds_endpoint" {
  value = "${aws_db_instance.micropost.endpoint}"
}

// I have only one node..
output "redis_endpoint" {
  value = "${aws_elasticache_cluster.micropost.cache_nodes.0.address}:${aws_elasticache_cluster.micropost.cache_nodes.0.port}"
}

