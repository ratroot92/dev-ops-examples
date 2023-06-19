provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
      #  version = "~> 3.0"
    }
  }
}



resource "aws_vpc" "aws_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" : "${var.env_prefix}-aws_vpc"
  }
}


resource "aws_internet_gateway" "aws_internet_gateway" {
  vpc_id = aws_vpc.aws_vpc.id
  tags = {
    "Name" : "${var.env_prefix}-aws_internet_gateway"

  }

}

resource "aws_subnet" "aws_subnet_private_us_east_1a" {
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = "10.0.0.0/19" // 8192k machines
  availability_zone = "us-east-1a"
  tags = {
    "Name"                                              = "${var.env_prefix}-aws_subnet_private_us_east_1a"
    "kubernetes.io/role/internal-elb"                   = "1"     // required for kubernetes to discover subnets where private loadbalancers will be created
    "kubernetes.io/cluster/burency_dev-aws_eks_cluster" = "owned" // you need to tag your cluster equal to eks cluster name in this case its 'demo'

  }

}

resource "aws_subnet" "aws_subnet_private_us_east_1b" {
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = "10.0.32.0/19" // 8192k machines
  availability_zone = "us-east-1b"
  tags = {
    "Name"                                              = "${var.env_prefix}-aws_subnet_private_us_east_1b"
    "kubernetes.io/role/internal-elb"                   = "1"     // required for kubernetes to discover subnets where private loadbalancers will be created
    "kubernetes.io/cluster/burency_dev-aws_eks_cluster" = "owned" // you need to tag your cluster equal to eks cluster name in this case its 'demo'

  }

}

resource "aws_subnet" "aws_subnet_public_us_east_1a" {
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = "10.0.96.0/19" // 8192k machines
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name"                                              = "${var.env_prefix}-aws_subnet_public_us_east_1a"
    "kubernetes.io/role/elb"                            = "1"     // this instructs kubernetes to create public load balancers in these subnets
    "kubernetes.io/cluster/burency_dev-aws_eks_cluster" = "owned" // you need to tag your cluster equal to eks cluster name in this case its 'demo'

  }

}

resource "aws_subnet" "aws_subnet_public_us_east_1b" {
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = "10.0.64.0/19" // 8192k machines
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    "Name"                                              = "${var.env_prefix}-aws_subnet_public_us_east_1b"
    "kubernetes.io/role/elb"                            = "1"     // this instructs kubernetes to create public load balancers in these subnets
    "kubernetes.io/cluster/burency_dev-aws_eks_cluster" = "owned" // you need to tag your cluster equal to eks cluster name in this case its 'demo'

  }

}


resource "aws_eip" "aws_eip_1" {
  vpc = true
  tags = {
    "Name" = "${var.env_prefix}-aws_eip_1"
  }

}


resource "aws_eip" "aws_eip_2" {
  vpc = true
  tags = {
    "Name" = "${var.env_prefix}-aws_eip_2"
  }

}



resource "aws_nat_gateway" "aws_nat_gateway_1" {
  allocation_id = aws_eip.aws_eip_1.id
  subnet_id     = aws_subnet.aws_subnet_public_us_east_1a.id
  tags = {
    "Name" = "${var.env_prefix}-aws_nat_gateway_1"
  }
  depends_on = [aws_internet_gateway.aws_internet_gateway]

}

resource "aws_nat_gateway" "aws_nat_gateway_2" {
  allocation_id = aws_eip.aws_eip_2.id
  subnet_id     = aws_subnet.aws_subnet_public_us_east_1b.id
  tags = {
    "Name" = "${var.env_prefix}-aws_nat_gateway_2"
  }
  depends_on = [aws_internet_gateway.aws_internet_gateway]

}

resource "aws_route_table" "aws_route_table_public" {
  vpc_id = aws_vpc.aws_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_internet_gateway.id
  }

  tags = {
    "Name" = "${var.env_prefix}-aws_route_table_public"
  }

}




resource "aws_route_table" "aws_route_table_private_1" {
  vpc_id = aws_vpc.aws_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.aws_nat_gateway_1.id
  }
  tags = {
    "Name" = "${var.env_prefix}-aws_route_table_private_1"
  }

}



resource "aws_route_table" "aws_route_table_private_2" {
  vpc_id = aws_vpc.aws_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.aws_nat_gateway_2.id
  }
  tags = {
    "Name" = "${var.env_prefix}-aws_route_table_private_2"
  }

}




resource "aws_route_table_association" "aws_route_table_association_public_us_east_1a" {
  subnet_id      = aws_subnet.aws_subnet_public_us_east_1a.id
  route_table_id = aws_route_table.aws_route_table_public.id
}

resource "aws_route_table_association" "aws_route_table_association_public_us_east_1b" {
  subnet_id      = aws_subnet.aws_subnet_public_us_east_1b.id
  route_table_id = aws_route_table.aws_route_table_public.id
}

resource "aws_route_table_association" "aws_route_table_association_private_us_east_1a" {
  subnet_id      = aws_subnet.aws_subnet_private_us_east_1a.id
  route_table_id = aws_route_table.aws_route_table_private_1.id
}

resource "aws_route_table_association" "aws_route_table_association_private_us_east_1b" {
  subnet_id      = aws_subnet.aws_subnet_private_us_east_1b.id
  route_table_id = aws_route_table.aws_route_table_private_2.id
}




resource "aws_iam_role" "eks_cluster_iam_role" {
  name = "${var.env_prefix}-eks_cluster_iam_role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      }

    }]
    Version = "2012-10-17"
  })

}





resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_iam_role.name

}



resource "aws_eks_cluster" "aws_eks_cluster" {
  name     = "${var.env_prefix}-aws_eks_cluster"
  role_arn = aws_iam_role.eks_cluster_iam_role.arn
  version  = "1.25"
  vpc_config {
    # endpoint_private_access = false
    # endpoint_public_access  = true
    subnet_ids = [
      aws_subnet.aws_subnet_private_us_east_1a.id,
      aws_subnet.aws_subnet_private_us_east_1b.id,
      aws_subnet.aws_subnet_public_us_east_1a.id,
      aws_subnet.aws_subnet_public_us_east_1b.id,
    ]
  }
  depends_on = [
    aws_iam_role_policy_attachment.aws_iam_role_policy_attachment_AmazonEKSClusterPolicy
  ]

}



resource "aws_iam_role" "cluster_nodes_iam_role" {
  name = "${var.env_prefix}-cluster_nodes_iam_role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com",
      }

    }]
    Version = "2012-10-17",
  })

}


resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.cluster_nodes_iam_role.name

}
resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.cluster_nodes_iam_role.name

}
resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.cluster_nodes_iam_role.name

}









resource "aws_iam_policy" "aws_iam_policy_AmazonEBSCSIDriverPolicy" {
  name = "${var.env_prefix}-aws_iam_policy_AmazonEBSCSIDriverPolicy"
  policy = jsonencode(

    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateSnapshot",
            "ec2:AttachVolume",
            "ec2:DetachVolume",
            "ec2:ModifyVolume",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeInstances",
            "ec2:DescribeSnapshots",
            "ec2:DescribeTags",
            "ec2:DescribeVolumes",
            "ec2:DescribeVolumesModifications"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateTags"
          ],
          "Resource" : [
            "arn:aws:ec2:*:*:volume/*",
            "arn:aws:ec2:*:*:snapshot/*"
          ],
          "Condition" : {
            "StringEquals" : {
              "ec2:CreateAction" : [
                "CreateVolume",
                "CreateSnapshot"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DeleteTags"
          ],
          "Resource" : [
            "arn:aws:ec2:*:*:volume/*",
            "arn:aws:ec2:*:*:snapshot/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateVolume"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "aws:RequestTag/ebs.csi.aws.com/cluster" : "true"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateVolume"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "aws:RequestTag/CSIVolumeName" : "*"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DeleteVolume"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "ec2:ResourceTag/ebs.csi.aws.com/cluster" : "true"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DeleteVolume"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "ec2:ResourceTag/CSIVolumeName" : "*"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DeleteVolume"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "ec2:ResourceTag/kubernetes.io/created-for/pvc/name" : "*"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DeleteSnapshot"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "ec2:ResourceTag/CSIVolumeSnapshotName" : "*"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DeleteSnapshot"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "ec2:ResourceTag/ebs.csi.aws.com/cluster" : "true"
            }
          }
        }
      ]
  })
}



resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_AmazonEBSCSIDriverPolicy" {
  policy_arn = aws_iam_policy.aws_iam_policy_AmazonEBSCSIDriverPolicy.arn
  role       = aws_iam_role.cluster_nodes_iam_role.name

}






resource "aws_eks_node_group" "aws_eks_node_group" {
  cluster_name    = aws_eks_cluster.aws_eks_cluster.name
  node_group_name = "${var.env_prefix}-aws_eks_node_group"
  node_role_arn   = aws_iam_role.cluster_nodes_iam_role.arn
  subnet_ids = [
    aws_subnet.aws_subnet_public_us_east_1a.id,
    aws_subnet.aws_subnet_public_us_east_1b.id,
  ]
  ami_type             = "AL2_x86_64"
  disk_size            = 100
  force_update_version = false
  instance_types       = ["${var.instance_types}"]
  capacity_type        = "ON_DEMAND"
  version              = "1.25"

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 1
  }


  update_config {
    max_unavailable = 1
  }
  labels = {
    # role = "general"
    role = "${var.env_prefix}-aws_eks_node_group"
  }




  depends_on = [
    aws_iam_role_policy_attachment.aws_iam_role_policy_attachment_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.aws_iam_role_policy_attachment_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.aws_iam_role_policy_attachment_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.aws_iam_role_policy_attachment_AmazonEBSCSIDriverPolicy,

  ]

}








#  open jenkins-ip:8080/
#  enter default password 
