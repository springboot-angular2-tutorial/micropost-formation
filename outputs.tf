output "ami_web" {
  value = "${var.ami_web}"
}

output "rds_endpoint" {
  value = "${aws_db_instance.micropost.endpoint}"
}

// I have only one node..
output "redis_endpoint" {
  value = "${aws_elasticache_cluster.micropost.cache_nodes.0.address}:${aws_elasticache_cluster.micropost.cache_nodes.0.port}"
}
