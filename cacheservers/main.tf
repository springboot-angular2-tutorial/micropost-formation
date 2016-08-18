resource "aws_elasticache_cluster" "cacheservers" {
  cluster_id = "cacheservers"
  engine = "redis"
  engine_version = "2.8.24"
  node_type = "cache.t2.micro"
  port = 6379
  num_cache_nodes = 1
  parameter_group_name = "default.redis2.8"
  security_group_ids = [
    "${var.security_groups}",
  ]
  subnet_group_name = "${aws_elasticache_subnet_group.cacheservers.name}"
}

resource "aws_elasticache_subnet_group" "cacheservers" {
  name = "cacheservers"
  description = "main subnet group"
  subnet_ids = [
    "${var.subnets}"
  ]
}