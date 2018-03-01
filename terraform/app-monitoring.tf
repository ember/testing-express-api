resource "aws_iam_user" "lb" {
  name = "prometheus-user"
  path = "/"
}

resource "aws_iam_access_key" "lb" {
  user = "${aws_iam_user.lb.name}"
}

resource "aws_iam_user_policy" "lb_ro" {
  name = "PrometheusReadOnly"
  user = "${aws_iam_user.lb.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:Describe*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:Describe*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:Describe*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:Describe*",
            "Resource": "*"
        }
    ]
}
EOF
}

data "template_file" "user_data_prom" {
  template = "${file("${path.module}/user_data/app-monitoring.tpl")}"

  vars {
    prom_access_key    = "${aws_iam_access_key.lb.id}"
    prom_access_secret = "${aws_iam_access_key.lb.secret}"
    aws_region         = "${var.aws_region}"
  }
}

resource "aws_instance" "prometheus_instance" {
  ami             = "${data.aws_ami.ubuntu_ami.id}"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.prometheus.id}"]
  subnet_id       = "${aws_subnet.public_az1.id}"
  user_data       = "${data.template_file.user_data_prom.rendered}"
  depends_on      = ["aws_autoscaling_group.asg_web_app"]

  tags {
    Name = "${var.app_name}-monitoring"
  }
}
