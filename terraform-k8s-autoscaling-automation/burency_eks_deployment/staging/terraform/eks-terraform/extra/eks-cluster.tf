
# /* IAM Role with AmazonEKSClusterPolicy */
# resource "aws_iam_role" "demo" {
#   name = "eks-cluster-demo"
#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole",
#       Effect = "Allow",
#       Principal = {
#         Service = "eks.amazonaws.com"
#       }

#     }]
#     Version = "2012-10-17"
#   })

# }





# resource "aws_iam_role_policy_attachment" "demo-AmazonEKSClusterPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.demo.name

# }



# resource "aws_eks_cluster" "demo" {
#   name     = "demo"
#   role_arn = aws_iam_role.demo.arn
#   vpc_config {
#     subnet_ids = [
#       aws_subnet.private-us-east-1a.id,
#       aws_subnet.private-us-east-1b.id,
#       aws_subnet.public-us-east-1a.id,
#       aws_subnet.public-us-east-1b.id,

#     ]
#   }
#   depends_on = [
#     aws_iam_role_policy_attachment.demo-AmazonEKSClusterPolicy
#   ]

# }
