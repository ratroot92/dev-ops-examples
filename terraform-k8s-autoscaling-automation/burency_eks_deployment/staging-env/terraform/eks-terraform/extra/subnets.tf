# resource "aws_subnet" "private-us-east-1a" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.0.0/19" // 8192k machines
#   availability_zone = "us-east-1a"
#   tags = {
#     "Name"                            = "private-us-east-1a"
#     "kubernetes.io/role/internal-elb" = "1"     // required for kubernetes to discover subnets where private loadbalancers will be created
#     "kubernetes.io/cluster/demo"      = "owned" // you need to tag your cluster equal to eks cluster name in this case its 'demo'

#   }

# }


# resource "aws_subnet" "private-us-east-1b" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.32.0/19" // 8192k machines
#   availability_zone = "us-east-1b"
#   tags = {
#     "Name"                            = "private-us-east-1b"
#     "kubernetes.io/role/internal-elb" = "1"     // required for kubernetes to discover subnets where private loadbalancers will be created
#     "kubernetes.io/cluster/demo"      = "owned" // you need to tag your cluster equal to eks cluster name in this case its 'demo'

#   }

# }


# resource "aws_subnet" "public-us-east-1a" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.96.0/19" // 8192k machines
#   availability_zone       = "us-east-1a"
#   map_public_ip_on_launch = true
#   tags = {
#     "Name"                       = "public-us-east-1a"
#     "kubernetes.io/role/elb"     = "1"     // this instructs kubernetes to create public load balancers in these subnets
#     "kubernetes.io/cluster/demo" = "owned" // you need to tag your cluster equal to eks cluster name in this case its 'demo'

#   }

# }



# resource "aws_subnet" "public-us-east-1b" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.64.0/19" // 8192k machines
#   availability_zone       = "us-east-1b"
#   map_public_ip_on_launch = true
#   tags = {
#     "Name"                       = "public-us-east-1b"
#     "kubernetes.io/role/elb"     = "1"     // this instructs kubernetes to create public load balancers in these subnets
#     "kubernetes.io/cluster/demo" = "owned" // you need to tag your cluster equal to eks cluster name in this case its 'demo'

#   }

# }
