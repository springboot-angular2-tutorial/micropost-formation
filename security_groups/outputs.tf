output "internal" {
  value = "${aws_security_group.internal.id}"
}

output "internet_in_ssh" {
  value = "${aws_security_group.internet_in_ssh.id}"
}

output "internet_in_http" {
  value = "${aws_security_group.internet_in_http.id}"
}

output "internet_in_https" {
  value = "${aws_security_group.internet_in_https.id}"
}
