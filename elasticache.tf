resource "aws_elasticache_cluster" "micropost" {
  cluster_id = "micropost-${var.env}"
  engine = "redis"
  engine_version = "2.8.24"
  node_type = "cache.t2.micro"
  port = 6379
  num_cache_nodes = 1
  parameter_group_name = "default.redis2.8"
  security_group_ids = [
    "${aws_security_group.internal.id}",
  ]
  subnet_group_name = "${aws_elasticache_subnet_group.micropost.name}"
}

resource "aws_elasticache_subnet_group" "micropost" {
  name = "micropost-${var.env}"
  description = "main subnet group"
  subnet_ids = [
    "${aws_subnet.private-a.id}",
    "${aws_subnet.private-b.id}",
  ]
}