resource "aws_security_group" "app-web" {
  name        = "${var.app_name}"
  description = "${var.app_name}-app-web"
  vpc_id      = "${aws_vpc.vpc_app.id}"

  ingress {
    from_port   = "${var.app_port}"
    to_port     = "${var.app_port}"
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.vpc_app.cidr_block}"]
  }

  ingress {
    from_port   = "9100"
    to_port     = "9100"
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.vpc_app.cidr_block}"]
  }

  ingress {
    from_port   = "8080"
    to_port     = "8080"
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.vpc_app.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "prometheus" {
  name        = "${var.app_name}-monitoring"
  description = "${var.app_name}-monitoring"
  vpc_id      = "${aws_vpc.vpc_app.id}"

  ingress {
    from_port   = "3000"
    to_port     = "3000"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb_web" {
  name        = "${var.app_name}-elb"
  description = "${var.app_name}-elb"
  vpc_id      = "${aws_vpc.vpc_app.id}"

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
