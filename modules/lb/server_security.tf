resource "aws_vpc_security_group_ingress_rule" "http_lb_to_server" {
  security_group_id = var.server_security_group_id

  description                  = "Allow http connections from the load balancer"
  from_port                    = var.server_port
  to_port                      = var.server_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.load_balancer_sg.id
}
