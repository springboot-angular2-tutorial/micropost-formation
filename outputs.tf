output "web_ami" {
  value = "${module.webservers.ami}"
}

output "web_desired_capacity" {
  value = "${module.webservers.desired_capacity}"
}

output "web_asg_name" {
  value = "${module.webservers.asg_name}"
}
