#!/bin/bash
set -e

# ============================================================
# Event Vault Finance - AWS ECS Fargate Deployment Script
# ============================================================
# Usage: ./deploy/deploy.sh
#
# Environment variables (optional overrides):
#   AWS_REGION       - AWS region to deploy to (default: us-east-1)
#   ECR_REPO_NAME    - ECR repository name (default: event-vault-finance)
#   STACK_NAME       - CloudFormation stack name (default: event-vault-finance-stack)
# ============================================================

AWS_REGION=${AWS_REGION:-us-east-1}
ECR_REPO_NAME=${ECR_REPO_NAME:-event-vault-finance}
STACK_NAME=${STACK_NAME:-event-vault-finance-stack}

echo "=========================================="
echo "Event Vault Finance - Deployment"
echo "=========================================="
echo "Region:     $AWS_REGION"
echo "Stack:      $STACK_NAME"
echo "ECR Repo:   $ECR_REPO_NAME"
echo "=========================================="

# 1. Build the Spring Boot JAR
echo ""
echo "[1/6] Building Spring Boot JAR..."
./gradlew clean bootJar

# 2. Deploy CloudFormation stack (creates ECR, ECS, ALB, etc.)
echo ""
echo "[2/6] Deploying CloudFormation stack..."
aws cloudformation deploy \
  --template-file deploy/cloudformation.yml \
  --stack-name "$STACK_NAME" \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --region "$AWS_REGION" \
  --no-fail-on-empty-changeset

# 3. Get ECR repo URI from stack outputs
echo ""
echo "[3/6] Retrieving ECR repository URI..."
ECR_URI=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[?OutputKey=='ECRRepositoryUri'].OutputValue" \
  --output text --region "$AWS_REGION")

echo "ECR URI: $ECR_URI"

# 4. Docker login to ECR
echo ""
echo "[4/6] Authenticating Docker with ECR..."
aws ecr get-login-password --region "$AWS_REGION" | \
  docker login --username AWS --password-stdin "$ECR_URI"

# 5. Build and push Docker image
echo ""
echo "[5/6] Building and pushing Docker image..."
docker build -t "$ECR_REPO_NAME" .
docker tag "$ECR_REPO_NAME:latest" "$ECR_URI:latest"
docker push "$ECR_URI:latest"

# 6. Force new deployment to pick up the new image
echo ""
echo "[6/6] Forcing new ECS deployment..."
CLUSTER_NAME=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[?OutputKey=='ClusterName'].OutputValue" \
  --output text --region "$AWS_REGION")

SERVICE_NAME=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[?OutputKey=='ServiceName'].OutputValue" \
  --output text --region "$AWS_REGION")

aws ecs update-service \
  --cluster "$CLUSTER_NAME" \
  --service "$SERVICE_NAME" \
  --force-new-deployment \
  --region "$AWS_REGION"

# Print the ALB URL
echo ""
echo "=========================================="
echo "Deployment complete!"
echo "=========================================="
ALB_DNS=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[?OutputKey=='LoadBalancerDNS'].OutputValue" \
  --output text --region "$AWS_REGION")

echo "Application URL: http://$ALB_DNS"
echo "Health Check:    http://$ALB_DNS/actuator/health"
echo "=========================================="
