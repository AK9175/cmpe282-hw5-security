#!/bin/bash
# Part B: IAM Role + EC2 Setup Script

# Create IAM role with EC2 trust policy
aws iam create-role \
  --role-name hw5-s3-readonly-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }' \
  --description "HW5 - S3 Read-Only Role for EC2"

# Attach S3 read-only managed policy
aws iam attach-role-policy \
  --role-name hw5-s3-readonly-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Create instance profile and attach role
aws iam create-instance-profile \
  --instance-profile-name hw5-s3-readonly-profile

aws iam add-role-to-instance-profile \
  --instance-profile-name hw5-s3-readonly-profile \
  --role-name hw5-s3-readonly-role

echo "IAM role and instance profile created successfully"

# Launch EC2 instance with IAM role
AMI_ID=$(aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" "Name=state,Values=available" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text)

aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t2.micro \
  --key-name hw5-key \
  --iam-instance-profile Name=hw5-s3-readonly-profile \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=hw5-s3-app-server}]'

echo "EC2 instance launched with IAM role attached"
