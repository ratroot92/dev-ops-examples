# resource "aws_iam_role" "nodes" {
#   name = "eks-node-group-nodes"
#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow",
#       Principal = {
#         Service = "ec2.amazonaws.com",


#       }

#     }]
#     Version = "2012-10-17",
#   })

# }


# resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.nodes.name

# }
# resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.nodes.name

# }
# resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.nodes.name

# }
# resource "aws_iam_policy" "test-policy-AmazonEBSCSIDriverPolicy" {
#   name = "test-policy-AmazonEBSCSIDriverPolicy"

#   policy = jsonencode(
#     {
#       "Version" = "2012-10-17",
#       "Statement" = [
#         {
#           Effect = "Allow"
#           Action = [
#             "ec2:CreateSnapshot",
#             "ec2:AttachVolume",
#             "ec2:DetachVolume",
#             "ec2:ModifyVolume",
#             "ec2:DescribeAvailabilityZones",
#             "ec2:DescribeInstances",
#             "ec2:DescribeSnapshots",
#             "ec2:DescribeTags",
#             "ec2:DescribeVolumes",
#             "ec2:DescribeVolumesModifications"
#           ]
#           Resource = "*"
#         },
#         {
#           Effect = "Allow"
#           Action = [
#             "ec2:CreateTags"
#           ]
#           Resource = [
#           ]
#           "Condition" = {
#             "StringEquals" = {
#               "ec2:CreateAction" = [
#                 "CreateVolume",
#                 "CreateSnapshot"
#               ]
#             }
#           }
#         },
#         {
#           Effect = "Allow"
#           Action = [
#             "ec2:DeleteTags"
#           ]
#           Resource = [
#           ]
#         },
#         {
#           Effect = "Allow"
#           Action = [
#             "ec2:CreateVolume"
#           ]
#           Resource = "*",
#           "Condition" = {
#             "StringLike" = {
#               "aws:RequestTag/ebs.csi.aws.com/cluster" = "true"
#             }
#           }
#         },
#         {
#           Effect = "Allow"
#           Action = [
#             "ec2:CreateVolume"
#           ]
#           Resource = "*",
#           "Condition" = {
#             "StringLike" = {
#               "aws:RequestTag/CSIVolumeName" = "*"
#             }
#           }
#         },
#         {
#           Effect = "Allow"
#           Action = [
#             "ec2:DeleteVolume"
#           ]
#           Resource = "*",
#           "Condition" = {
#             "StringLike" = {
#               "ec2:ResourceTag/ebs.csi.aws.com/cluster" = "true"
#             }
#           }
#         },
#         {
#           Effect = "Allow"
#           Action = [
#             "ec2:DeleteVolume"
#           ]
#           Resource = "*",
#           "Condition" = {
#             "StringLike" = {
#               "ec2:ResourceTag/CSIVolumeName" = "*"
#             }
#           }
#         },
#         {
#           Effect = "Allow"
#           Action = [
#             "ec2:DeleteVolume"
#           ]
#           Resource = "*",
#           "Condition" = {
#             "StringLike" = {
#               "ec2:ResourceTag/kubernetes.io/created-for/pvc/name" = "*"
#             }
#           }
#         },
#         {
#           Effect = "Allow"
#           Action = [
#             "ec2:DeleteSnapshot"
#           ]
#           Resource = "*",
#           "Condition" = {
#             "StringLike" = {
#               "ec2:ResourceTag/CSIVolumeSnapshotName" = "*"
#             }
#           }
#         },
#         {
#           Effect = "Allow"
#           Action = [
#             "ec2:DeleteSnapshot"
#           ]
#           Resource = "*",
#           "Condition" = {
#             "StringLike" = {
#               "ec2:ResourceTag/ebs.csi.aws.com/cluster" = "true"
#             }
#           }
#         }
#       ]
#     }
#   )
# }



# resource "aws_iam_role_policy_attachment" "nodes-AmazonEBSCSIDriverPolicy" {
#   policy_arn = aws_iam_policy.test-policy-AmazonEBSCSIDriverPolicy.arn
#   role       = aws_iam_role.nodes.name

# }








# resource "aws_eks_node_group" "public-nodes" {
#   cluster_name    = aws_eks_cluster.demo.name
#   node_group_name = "public-nodes"
#   node_role_arn   = aws_iam_role.nodes.arn
#   subnet_ids = [
#     aws_subnet.public-us-east-1a.id,
#     aws_subnet.public-us-east-1b.id,

#   ]
#   capacity_type  = "ON_DEMAND"
#   instance_types = ["t2.medium"]

#   scaling_config {

#     desired_size = 4
#     max_size     = 6
#     min_size     = 1
#   }


#   update_config {
#     max_unavailable = 1
#   }
#   labels = {
#     role = "general"
#   }




#   depends_on = [
#     aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
#     aws_iam_role_policy_attachment.nodes-AmazonEBSCSIDriverPolicy,

#   ]

# }





