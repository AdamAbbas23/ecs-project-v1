# ECS Project V1

## Project Overview

This project demonstrates a production-grade containerised application deployment on AWS. Threat Composer App is a threat modeling system that helps you identify security issues and develop strategies to address them. The application is containerised using Docker, stored in Amazon ECR, and deployed to ECS Fargate with all infrastructure provisioned as code using Terraform.

The infrastructure includes a VPC with public and private subnets across two availability zones, an Application Load Balancer for HTTPS traffic, ACM for SSL termination, and Route53 for DNS.

Two CI/CD pipelines automate the entire workflow:
- **Build pipeline** — triggered on every push to `main`, builds the Docker image and pushes it to ECR tagged with the commit SHA
- **Deploy pipeline** — triggered when the build pipeline completes, runs Terraform to update the ECS task definition with the new image and redeploys the container

This ensures any code change is automatically built, deployed and verified — keeping the application continuously up to date without manual intervention.

---

## App Demo

<img width="1686" height="1366" alt="Screenshot 2026-10-02 at 09 59 44" src="https://github.com/user-attachments/assets/9485c90e-f85f-496d-8b09-d802d53951df" />


---

## Local Setup

**Prerequisites**
- Terraform
- AWS CLI
- Docker
- Git

> ⚠️ If you are on Apple Silicon (M1/M2/M3) ensure your task definition uses `cpu_architecture = "ARM64"`. If deploying via the CI/CD pipeline, use `X86_64` as GitHub Actions runs on AMD64.

**Steps**

1. Clone the repository
```bash
git clone https://github.com/AdamAbbas23/ecs-project-v1.git
cd ecs-project-v1
```

2. Configure AWS credentials
```bash
aws configure
```

3. Run bootstrap first — creates S3 remote state bucket and OIDC provider for GitHub Actions
```bash
cd terraform/bootstrap
terraform init
terraform apply
```

4. Deploy infrastructure
```bash
cd ../
terraform init
terraform apply
```

5. Push Docker image to ECR
```bash
cd ecs-assignment
docker build -t <your-ecr-url>:latest .
docker push <your-ecr-url>:latest
```

---

## Architecture Diagram
<img width="787" height="1447" alt="ecs-Page-1 drawio" src="https://github.com/user-attachments/assets/a8d0d222-4544-4bdd-832d-f04507a664af" />


---

## Project Structure
```
├── .github/
│   └── workflows/
│       ├── docker.yml
│       └── deploy.yml
│
├── ecs-assignment/
│
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── modules/
    │   ├── vpc/
    │   ├── ecr/
    │   ├── iam/
    │   ├── security_groups/
    │   ├── acm/
    │   ├── alb/
    │   ├── ecs/
    │   └── route53/
    └── bootstrap/
```

---

## Pipeline Screenshots

<img width="1686" height="971" alt="Screenshot 2026-10-02 at 09 36 45" src="https://github.com/user-attachments/assets/7ef4690d-bd1a-4735-bd71-93b97d83011b" />
<img width="1701" height="1062" alt="Screenshot 2026-10-02 at 09 35 06" src="https://github.com/user-attachments/assets/06355861-2472-428a-a38c-79a03958306d" />

## Security Practices

- **Private subnets for containers** — ECS tasks run in private subnets with no direct internet access. The only way to reach the container is through the ALB
- **Layered security groups** — `alb-sg` only allows port 80/443 from the internet. `ecs-tasks-sg` only allows port 80 from `alb-sg` and not from the internet directly
- **OIDC for CI/CD** — no static AWS keys stored in GitHub. GitHub Actions receives temporary credentials that expire after each pipeline run
- **HTTPS enforced** — ACM certificate attached to ALB, port 80 redirects to 443, all traffic encrypted in transit
- **SSL termination at ALB** — container never handles encryption, reducing attack surface
- **Remote state in S3** — Terraform state stored remotely with locking, not committed to version control
- **`terraform.tfvars` gitignored** — sensitive variable values never committed to the repo

---

### What I would improve in production

- **Least privilege IAM** — replace `AdministratorAccess` on the GitHub Actions role with only the specific permissions Terraform needs (ECS, ECR, VPC, ALB, Route53, ACM, S3)
- **Multiple NAT Gateways** — currently one NAT Gateway in a single AZ. If that AZ goes down, all private subnet outbound traffic fails. 
- **Pipeline vulnerability scanning** — add Grype or Trivy to the build pipeline to scan images before pushing to ECR. This fails the pipeline early if anything critical is found, preventing vulnerable images from ever reaching production. 
