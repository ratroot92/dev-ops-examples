


data "tls_certificate" "burency_tls_certificate" {
  url = aws_eks_cluster.aws_eks_cluster.identity[0].oidc[0].issuer


}


resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.burency_tls_certificate.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.aws_eks_cluster.identity[0].oidc[0].issuer

}
