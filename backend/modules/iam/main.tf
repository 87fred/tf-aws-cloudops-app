#Define quem pode assumir a role
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${terraform.workspace}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

#Define as permissões (políticas) que a Role terá
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#Define as permissões (políticas) que a Role terá para acessar o DynamoDB
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "${var.project_name}-${terraform.workspace}-lambda-dynamodb-policy"
  description = "Permissões para a Lambda ler e escrever na tabela de usuários do DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = var.dynamodb_table_name
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

#Política para leitura dos serviços provisionados na infraestrutura
resource "aws_iam_policy" "lambda_dashboard_policy" {
  name        = "${var.project_name}-${terraform.workspace}-lambda-dashboard-policy"
  description = "Permissões para o dashboard de observabilidade (cloudwatch, s3, dynamodb, sns, sqs, etc.)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Compute & Orchestration
          "ec2:DescribeInstances",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ecs:ListClusters",
          "ecs:DescribeClusters",
          "ecs:ListServices",
          "ecs:DescribeServices",
          "ecs:ListTasks",
          "lambda:ListFunctions",

          # Databases
          "rds:DescribeDBInstances",
          "dynamodb:ListTables",

          # Storage & Networking
          "s3:ListAllMyBuckets",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",

          # Observability (Monitoramento)
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",

          # FinOps (Custos)
          "ce:GetCostAndUsage",

          # IAM
          "iam:ListRoles"
        ]
        Resource = "*"
      },
    ]
  })
}
#anexando a policy a mesma role da lambda
resource "aws_iam_role_policy_attachment" "lambda_dashboard_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dashboard_policy.arn
}
