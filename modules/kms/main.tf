data "aws_caller_identity" "current" {}

resource "aws_kms_key" "mvr_key" {
  description             = "KMS key for symmetric encryption at rest"
  enable_key_rotation     = true // idk
  deletion_window_in_days = 30

  tags = {
    Name        = "${var.app_name}-kms-key"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_kms_key_policy" "example" {
  key_id = aws_kms_key.example.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-consolepolicy-x"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.principal_accounts}:root"
        },
        Action   = "kms:*"
        Resource = aws_kms_key.mvr_key.arn
      },
      {
        Sid : "Allow access for Key Administrators",
        Effect : "Allow",
        Principal : {
          AWS : [
            var.kms_role,
            var.codepipeline_role,
            var.codebuild_role
          ]
        },
        Action : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource : "${aws_kms_key.mvr_key.arn}"
      },
      {
        Sid : "Allow use of the key",
        Effect : "Allow",
        Principal : {
          AWS : [
            var.kms_role,
            var.codepipeline_role,
            var.codebuild_role
          ]
        },
        Action : [
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext"
        ],
        "Resource" : "${aws_kms_key.mvr_key.arn}"
      }
    ]
  })
}