#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "otf-node" {
  name = "terraform-eks-otf-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "otf-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.otf-node.name
}

resource "aws_iam_role_policy_attachment" "otf-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.otf-node.name
}

resource "aws_iam_role_policy_attachment" "otf-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.otf-node.name
}

resource "aws_eks_node_group" "otf" {
    cluster_name    = aws_eks_cluster.otf.name
    node_group_name = "otf"
    node_role_arn   = aws_iam_role.otf-node.arn
    subnet_ids      = aws_subnet.otf[*].id
  //instance_types = [ "t3.small" ] # (2 ram , 1 CPU) 	$0.0418 /hour * 2  ~ 30 $ Month
    instance_types = [ "t3.medium" ] # (4 ram , 2 CPU) 	$0.0418 /hour * 2  ~ 60 $ Month

    scaling_config {
        desired_size = 1
        max_size     = 1
        min_size     = 1
    }

    # lifecycle {
    #  ignore_changes = [scaling_config.0.desired_size]
    #}

    depends_on = [
        aws_iam_role_policy_attachment.otf-node-AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.otf-node-AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.otf-node-AmazonEC2ContainerRegistryReadOnly,
    ]
}