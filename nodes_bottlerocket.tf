resource "aws_eks_node_group" "bottlerocket" {

  cluster_name    = aws_eks_cluster.main.id
  node_group_name = format("%s-bottlerocket", aws_eks_cluster.main.id)

  node_role_arn = aws_iam_role.eks_nodes_role.arn

  instance_types = var.nodes_instance_sizes

  subnet_ids = data.aws_ssm_parameter.pods_subnets[*].value

  scaling_config {
    desired_size = lookup(var.auto_scale_options, "desired")
    max_size     = lookup(var.auto_scale_options, "max")
    min_size     = lookup(var.auto_scale_options, "min")
  }

  labels = {
    "ingress/ready" = "true"
    "capacity/os" = "BOTTLEROCKET"
    "capacity/arch" = "x86_64"
    "capacity/type" = "ON_DEMAND"
  }

  capacity_type = "ON_DEMAND"

  ami_type = "BOTTLEROCKET_x86_64"

  tags = {
    "kubernetes.io/cluster/${var.project_name}" = "owned"
  }

  depends_on = [
    # kubernetes_config_map.aws-auth
    aws_eks_access_entry.nodes
  ]

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }

  timeouts {
    create = "1h"
    update = "2h"
    delete = "2h"
  }

}