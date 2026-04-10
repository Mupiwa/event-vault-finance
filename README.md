## 🚀 Name
Event-vault-finance (EVF)
---

## 📌 Vision
Build a **programmable money platform** where users define rules:
- “If I get paid → split into savings, rent, investments”
- “If invoice unpaid after 7 days → apply penalty”
- “If balance < $500 → move funds automatically”

This is **event-driven finance** powered by AWS.
git remote set-url origin git@github.com:Mupiwa/event-vault-finance.git
---

## 🏗 High-Level Architecture

### Event Layer
- Amazon MSK (Kafka)
- Amazon EventBridge

### Compute Layer
- AWS Lambda (rule evaluation)
- AWS Step Functions (workflow orchestration)

### Data Layer
- DynamoDB (rules, configs)
- Aurora Serverless (transactions, ledger)
- S3 (audit logs)

### API Layer
- API Gateway
- Cognito (authentication)

---

## 🧩 Core Features (MVP)

### 1. Rule Engine
- Users define rules (IF event → THEN action)
- Store rules in DynamoDB

### 2. Event Ingestion
- Payment events
- Account balance changes
- Scheduled triggers

### 3. Workflow Execution
- Step Functions executes multi-step financial logic

### 4. Payment Actions
- Split payments
- Schedule payments
- Conditional transfers

### 5. Audit & Logging
- Store all events in S3 for traceability

---

## ⚙️ AWS Services Breakdown

| Layer | Service | Purpose |
|------|--------|--------|
| Streaming | MSK (Kafka) | High-throughput event ingestion |
| Routing | EventBridge | Event filtering and routing |
| Compute | Lambda | Rule execution |
| Orchestration | Step Functions | Multi-step workflows |
| Storage | DynamoDB | Rules and configs |
| Storage | Aurora | Financial transactions |
| Storage | S3 | Audit logs |
| Security | Cognito | User authentication |

---

## 🧠 Key Engineering Challenges

- Exactly-once processing
- Idempotency for financial actions
- Retry + compensation logic
- Multi-tenant isolation
- Low latency event processing

---

## 🗺 Development Phases

### Phase 1: Foundation (Week 1–2)
- Set up AWS account & IAM roles
- Create API Gateway + Lambda
- Basic rule CRUD APIs
- DynamoDB schema design

### Phase 2: Event System (Week 3–4)
- Introduce EventBridge
- Define event schema
- Build event producers

### Phase 3: Rule Execution (Week 5–6)
- Lambda rule evaluator
- Trigger actions based on events

### Phase 4: Workflow Engine (Week 7–8)
- Implement Step Functions
- Add multi-step workflows

### Phase 5: Payments Simulation (Week 9–10)
- Simulate transactions
- Implement ledger in Aurora

### Phase 6: Scaling & Streaming (Week 11–12)
- Introduce MSK (Kafka)
- Handle high-volume events

---

## 🔐 Security Considerations

- IAM least privilege policies
- Encryption (KMS)
- Secure API Gateway endpoints
- Data isolation per user

---

## 📈 Future Enhancements

- AI rule suggestions (SageMaker)
- Real bank integrations (Plaid, Stripe)
- Mobile app
- Fraud detection layer
- Cross-user programmable contracts

---

## 🚢 Deployment

The application is deployed to **AWS ECS Fargate** using CloudFormation for infrastructure-as-code. The stack provisions a VPC, ALB, ECR repository, ECS cluster, and Fargate service.

### Prerequisites

- **AWS CLI** installed and configured with appropriate credentials (`aws configure`)
- **Docker** installed and running locally
- **Java 17+** and **Gradle** (or use the included Gradle Wrapper)
- AWS account with permissions to create VPC, ECS, ECR, ALB, IAM, and CloudWatch resources

### Architecture Overview

```
Internet → ALB (port 80) → ECS Fargate Service (port 8080) → Spring Boot App
                                      ↑
                              ECR (Docker image)
```

**Resources provisioned by CloudFormation:**
- VPC with 2 public subnets across 2 Availability Zones
- Internet Gateway with route tables
- Application Load Balancer (internet-facing) on port 80
- ECS Cluster with Fargate launch type
- ECR repository for Docker images
- CloudWatch Log Group for container logs
- Security groups (ALB: 80/443 inbound; ECS: 8080 from ALB only)
- IAM roles (Task Execution Role + Task Role)

### Deploy

Run the deployment script from the project root:

```bash
./deploy/deploy.sh
```

The script will:
1. Build the Spring Boot JAR (`./gradlew clean bootJar`)
2. Deploy/update the CloudFormation stack
3. Build and push the Docker image to ECR
4. Force a new ECS deployment to pick up the latest image
5. Print the ALB URL where the app is accessible

#### Environment Variable Overrides

| Variable | Default | Description |
|----------|---------|-------------|
| `AWS_REGION` | `us-east-1` | AWS region for deployment |
| `ECR_REPO_NAME` | `event-vault-finance` | ECR repository name |
| `STACK_NAME` | `event-vault-finance-stack` | CloudFormation stack name |

Example with overrides:

```bash
AWS_REGION=eu-west-1 ./deploy/deploy.sh
```

### Health Check

The ALB target group performs health checks against:

```
GET /actuator/health (port 8080)
```

### Tear Down

To delete all AWS resources created by the stack:

```bash
aws cloudformation delete-stack --stack-name event-vault-finance-stack --region us-east-1
```

> **Note:** You must manually delete any images in the ECR repository before the stack can be fully deleted, or empty the repository first:
> ```bash
> aws ecr batch-delete-image --repository-name event-vault-finance \
>   --image-ids "$(aws ecr list-images --repository-name event-vault-finance --query 'imageIds[*]' --output json)" \
>   --region us-east-1
> ```
