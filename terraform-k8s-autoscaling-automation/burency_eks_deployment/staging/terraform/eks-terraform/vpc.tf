resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" : "main"
  }
}


resource "aws_internet_gateway" "burency_main_vpc_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "burency_main_vpc_igw"
  }

}

resource "aws_subnet" "burency_subnet_private_us_east_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/19" // 8192k machines
  availability_zone = "us-east-1a"
  tags = {
    "Name"                              = "burency_subnet_private_us_east_1a"
    "kubernetes.io/role/internal-elb"   = "1"     // required for kubernetes to discover subnets where private loadbalancers will be created
    "kubernetes.io/cluster/burency_eks" = "owned" // you need to tag your cluster equal to eks cluster name in this case its 'demo'

  }

}

resource "aws_subnet" "burency_subnet_private_us_east_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.32.0/19" // 8192k machines
  availability_zone = "us-east-1b"
  tags = {
    "Name"                              = "burency_subnet_private_us_east_1b"
    "kubernetes.io/role/internal-elb"   = "1"     // required for kubernetes to discover subnets where private loadbalancers will be created
    "kubernetes.io/cluster/burency_eks" = "owned" // you need to tag your cluster equal to eks cluster name in this case its 'demo'

  }

}

resource "aws_subnet" "burency_subnet_public_us_east_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.96.0/19" // 8192k machines
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name"                              = "burency_subnet_public_us_east_1a"
    "kubernetes.io/role/elb"            = "1"     // this instructs kubernetes to create public load balancers in these subnets
    "kubernetes.io/cluster/burency_eks" = "owned" // you need to tag your cluster equal to eks cluster name in this case its 'demo'

  }

}

resource "aws_subnet" "burency_subnet_public_us_east_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.64.0/19" // 8192k machines
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    "Name"                              = "burency_subnet_public_us_east_1b"
    "kubernetes.io/role/elb"            = "1"     // this instructs kubernetes to create public load balancers in these subnets
    "kubernetes.io/cluster/burency_eks" = "owned" // you need to tag your cluster equal to eks cluster name in this case its 'demo'

  }

}


resource "aws_eip" "burency_eip_1" {
  vpc = true
  tags = {
    "Name" = "burency_eip_1"
  }

}


resource "aws_eip" "burency_eip_2" {
  vpc = true
  tags = {
    "Name" = "burency_eip_2"
  }

}



resource "aws_nat_gateway" "burency_natgw_1" {
  allocation_id = aws_eip.burency_eip_1.id
  subnet_id     = aws_subnet.burency_subnet_public_us_east_1a.id
  tags = {
    "Name" = "burency_natgw_1"
  }
  depends_on = [aws_internet_gateway.burency_main_vpc_igw]

}

resource "aws_nat_gateway" "burency_natgw_2" {
  allocation_id = aws_eip.burency_eip_2.id
  subnet_id     = aws_subnet.burency_subnet_public_us_east_1b.id
  tags = {
    "Name" = "burency_natgw_2"
  }
  depends_on = [aws_internet_gateway.burency_main_vpc_igw]

}

resource "aws_route_table" "burency_public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.burency_main_vpc_igw.id
  }

  tags = {
    "Name" = "burency_public_rt"
  }

}




resource "aws_route_table" "burency_private_rt_1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.burency_natgw_1.id
  }
  tags = {
    "Name" = "burency_private_rt_1"
  }

}



resource "aws_route_table" "burency_private_rt_2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.burency_natgw_1.id
  }
  tags = {
    "Name" = "burency_private_rt_2"
  }

}




resource "aws_route_table_association" "burency_subnet_public_us_east_1a" {
  subnet_id      = aws_subnet.burency_subnet_public_us_east_1a.id
  route_table_id = aws_route_table.burency_public_rt.id
}

resource "aws_route_table_association" "burency_subnet_public_us_east_1b" {
  subnet_id      = aws_subnet.burency_subnet_public_us_east_1b.id
  route_table_id = aws_route_table.burency_public_rt.id
}

resource "aws_route_table_association" "burency_subnet_private_us_east_1a" {
  subnet_id      = aws_subnet.burency_subnet_private_us_east_1a.id
  route_table_id = aws_route_table.burency_private_rt_1.id
}

resource "aws_route_table_association" "burency_subnet_private_us_east_1b" {
  subnet_id      = aws_subnet.burency_subnet_private_us_east_1b.id
  route_table_id = aws_route_table.burency_private_rt_2.id
}




resource "aws_iam_role" "burency_eks_cluster_role" {
  name = "burency_eks_cluster_role"
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





resource "aws_iam_role_policy_attachment" "burency_eks_cluster_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.burency_eks_cluster_role.name

}



resource "aws_eks_cluster" "burency_eks" {
  name     = "burency_eks"
  role_arn = aws_iam_role.burency_eks_cluster_role.arn
  version  = "1.25"
  vpc_config {
    # endpoint_private_access = false
    # endpoint_public_access  = true
    subnet_ids = [
      aws_subnet.burency_subnet_private_us_east_1a.id,
      aws_subnet.burency_subnet_private_us_east_1b.id,
      aws_subnet.burency_subnet_public_us_east_1a.id,
      aws_subnet.burency_subnet_public_us_east_1b.id,

    ]
  }
  depends_on = [
    aws_iam_role_policy_attachment.burency_eks_cluster_role_policy_attachment
  ]

}



resource "aws_iam_role" "burency_ec2_nodes_role" {
  name = "burency_ec2_nodes_role"
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


resource "aws_iam_role_policy_attachment" "burency_eks_nodes_policy_attachment_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.burency_ec2_nodes_role.name

}
resource "aws_iam_role_policy_attachment" "burency_eks_nodes_policy_attachment_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.burency_ec2_nodes_role.name

}
resource "aws_iam_role_policy_attachment" "burency_eks_nodes_policy_attachment_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.burency_ec2_nodes_role.name

}




resource "aws_iam_policy" "test-policy-AmazonEBSCSIDriverPolicy" {
  name = "test-policy-AmazonEBSCSIDriverPolicy"
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



resource "aws_iam_role_policy_attachment" "nodes-AmazonEBSCSIDriverPolicy" {
  policy_arn = aws_iam_policy.test-policy-AmazonEBSCSIDriverPolicy.arn
  role       = aws_iam_role.burency_ec2_nodes_role.name

}











resource "aws_eks_node_group" "burency_eks_node_group" {
  cluster_name    = aws_eks_cluster.burency_eks.name
  node_group_name = "burency_eks_node_group"
  node_role_arn   = aws_iam_role.burency_ec2_nodes_role.arn
  subnet_ids = [
    aws_subnet.burency_subnet_public_us_east_1a.id,
    aws_subnet.burency_subnet_public_us_east_1b.id,
  ]
  ami_type             = "AL2_x86_64"
  disk_size            = 100
  force_update_version = false
  instance_types       = ["t2.medium"]
  capacity_type        = "ON_DEMAND"
  version              = "1.25"

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 1
  }


  update_config {
    max_unavailable = 1
  }
  labels = {
    # role = "general"
    role = "burency_eks_node_group"
  }




  depends_on = [
    aws_iam_role_policy_attachment.burency_eks_nodes_policy_attachment_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.burency_eks_nodes_policy_attachment_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.burency_eks_nodes_policy_attachment_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.nodes-AmazonEBSCSIDriverPolicy,

  ]

}





