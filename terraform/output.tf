output "elb_address" {
  value = "${aws_elb.elb_app.dns_name}"
}

output "app_version" {
  value = "${var.api_version}"
}

output "prometheus-user-key" {
  value = "${aws_iam_access_key.lb.secret}"
}

output "grafana_web" {
  value = "${aws_instance.prometheus_instance.public_dns}"
}

output "grafana_port" {
  value = "${var.graf_http_port}"
}
