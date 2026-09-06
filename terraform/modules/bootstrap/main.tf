# resource "aws_s3_bucket" "ecs" {
#   bucket = "ecs-s3"

#   tags = {
#     Name        = "My bucket"
#     Environment = "Dev"
#   }
# }
resource "aws_iam_openid_connect_provider" "ecsoidc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}
resource "aws_iam_role" "bootstrap_role" {
  name = "bootstrap_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::706802417298:oidc-provider/token.actions.githubusercontent.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        # StringEquals = {
        #   "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        #   "token.actions.githubusercontent.com:sub" = "repo:AdamAbbas23/ecs-project-v1:ref:refs/heads/main"
        # }
        "Condition": {
        "StringEquals":{
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike":{
          "token.actions.githubusercontent.com:sub": "repo:AdamAbbas23/ecs-project-v1:*"
        }
}
      }
    }
  ]
})
}

resource "aws_iam_role_policy_attachment" "bootstrap" {
  role = aws_iam_role.bootstrap_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
