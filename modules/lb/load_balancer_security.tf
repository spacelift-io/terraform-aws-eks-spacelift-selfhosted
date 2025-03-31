resource "aws_security_group" "load_balancer_sg" {
  name        = "load_balancer_sg_${var.unique_suffix}"
  description = "Allow HTTP and HTTPS traffic to the load balancer"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "lb_http_towards_server" {
  security_group_id = aws_security_group.load_balancer_sg.id

  description                  = "Allow all traffic to the server"
  from_port                    = var.server_port
  to_port                      = var.server_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.server_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "tls" {
  security_group_id = aws_security_group.load_balancer_sg.id

  description = "Accept HTTP connections on port 443"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}
