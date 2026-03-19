resource "aws_iam_role" "traific_workloads" {
  name = "traific-workloads-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "stream_processor_s3" {
  role       = aws_iam_role.traific_workloads.name
  policy_arn = aws_iam_policy.stream_processor_s3.arn
}

resource "aws_iam_policy" "stream_processor_s3" {
  name        = "traific-stream-processor-s3"
  description = "Allows stream processor to write to S3 datalake and read RDS credentials"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3DatalakeWrite"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.datalake.arn,
          "${aws_s3_bucket.datalake.arn}/*"
        ]
      },
      {
        Sid    = "SecretsManagerRead"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:*:secret:traific/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "traific_workloads" {
  name = "traific-workloads-profile"
  role = aws_iam_role.traific_workloads.name
}

data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_name}-*"]
  }
  most_recent = true
  owners      = ["amazon"]
}
