# Create IAM Groups
resource "aws_iam_group" "education" {
  name = "Education"
  path = "/groups/"
}

resource "aws_iam_group" "engineering" {
  name = "Engineering"
  path = "/groups/"
}

resource "aws_iam_group" "managers" {
  name = "Managers"
  path = "/groups/"
}

# Add users to the Education group
resource "aws_iam_group_membership" "education_membership" {
  name = "education-membership"
  group = aws_iam_group.education.name
  users =[for user in aws_iam_user.users:
    user.name if user.tags["Department"] == "Education" || user.tags["Department"] == "Quality Assurance" || user.tags["Department"] == "HR" || user.tags["Department"] == "Sales"
  ]
  
}

# Add users to the Engineering group
resource "aws_iam_group_membership" "engineering_membership" {
  name = "engineering-membership"
  group = aws_iam_group.engineering.name
  users =[for user in aws_iam_user.users:
    user.name if user.tags["Department"] == "Engineering"
  ]
}

# Add users to the Managers group
resource "aws_iam_group_membership" "managers_membership" {
  name = "managers-membership"
  group = aws_iam_group.managers.name
  users =[for user in aws_iam_user.users:
    user.name if user.tags["Department"] == "Manager" || user.tags["Department"] == "Corporate"
  ] 
}


# -----------------------------------------------------------
# GROUP POLICIES
# -----------------------------------------------------------

resource "aws_iam_group_policy" "engineering_policy" {
  name  = "engineering_full_EC2_access"
  group = aws_iam_group.engineering.name

  # jsonencode converts the HCL object to a JSON string automatically.
  # This is less error-prone than pasting raw JSON strings.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "ec2:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "elasticloadbalancing:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "cloudwatch:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "autoscaling:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "iam:CreateServiceLinkedRole"
        Effect   = "Allow"
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = [
              "autoscaling.amazonaws.com",
              "ec2scheduled.amazonaws.com",
              "elasticloadbalancing.amazonaws.com",
              "spot.amazonaws.com",
              "spotfleet.amazonaws.com",
              "transitgateway.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_group_policy" "managers_policy" {
  group = aws_iam_group.managers.name
  name  = "managers_read_only_access"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_group_policy" "education_policy" {
  name  = "education_S3_access"
  group = aws_iam_group.education.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::example-bucket",
          "arn:aws:s3:::example-bucket/*"
        ]
      }
    ]
  })
}