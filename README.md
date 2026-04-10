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
