# AWS Deployment Guide (Docker & ECS)

This guide walks you through deploying the `TOPS Placement AI Agent` Streamlit application to **AWS Elastic Container Service (ECS)** using **AWS Fargate** and **GitHub Actions**.

## Prerequisites
1. An AWS Account.
2. AWS CLI installed and configured locally (optional but helpful).
3. The project pushed to a GitHub repository.

## 1. Local Docker Testing (Optional)
Before deploying, ensure your app works locally via Docker:
```bash
docker build -t tops-agent .
docker run -p 8501:8501 -e GEMINI_API_KEY="your-api-key" tops-agent
```
Visit `http://localhost:8501`.

## 2. AWS Setup

### A. Create an ECR Repository
1. Go to AWS Console -> **Elastic Container Registry (ECR)**.
2. Click **Create repository**.
3. Name it `tops-placement-agent` and click **Create**.

### B. Create an ECS Cluster
1. Go to AWS Console -> **Elastic Container Service (ECS)**.
2. Click **Create cluster**.
3. Name it `tops-placement-cluster`. Select **AWS Fargate** as the infrastructure. Click **Create**.

### C. Create a Task Definition
1. In ECS, go to **Task definitions** -> **Create new task definition**.
2. Name it `tops-placement-task`.
3. Launch type: **Fargate**.
4. OS/Architecture: Linux/X86_64.
5. Task memory: 2GB, Task CPU: 1 vCPU (Streamlit and PDF parsing can be memory intensive).
6. **Container details**:
   - Name: `tops-placement-container`
   - Image URI: `[YOUR_AWS_ACCOUNT_ID].dkr.ecr.[AWS_REGION].amazonaws.com/tops-placement-agent:latest` (you will replace this later via CI/CD, but put a placeholder).
   - Port mappings: Container port `8501`, Protocol `TCP`.
7. Download the JSON version of this task definition. Create a folder named `.aws` in your repository and save it as `.aws/task-definition.json`.

### D. Create an ECS Service
1. Go to your `tops-placement-cluster`.
2. Under the Services tab, click **Create**.
3. Compute options: **Launch type** -> **FARGATE**.
4. Deployment configuration -> Application type: **Service**.
5. Task Definition -> Family: `tops-placement-task`.
6. Service name: `tops-placement-service`.
7. **Networking**: Ensure your VPC has a public subnet. Choose a Security Group that allows inbound TCP traffic on port `8501` and port `80`. Ensure "Auto-assign public IP" is **ENABLED**.
8. Click **Create**.

## 3. GitHub Actions Setup
We have provided `.github/workflows/deploy-aws.yml`.

To make it work, add these **Repository Secrets** in your GitHub Repo (`Settings > Secrets and variables > Actions`):
- `AWS_ACCESS_KEY_ID`: An IAM User access key with permissions to push to ECR and update ECS.
- `AWS_SECRET_ACCESS_KEY`: The secret key for the IAM user.

Ensure the `env` block in `.github/workflows/deploy-aws.yml` matches the names you used:
```yaml
env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: tops-placement-agent
  ECS_SERVICE: tops-placement-service
  ...
```

Now, every time you push to the `main` branch, GitHub Actions will automatically:
1. Build the Docker image.
2. Push it to ECR.
3. Update the ECS Task Definition with the new image.
4. Deploy the new Task to your ECS Service.

## 4. Accessing Your App
Once deployed, go to your ECS Service -> Tasks -> Click on the running task -> **ENI Id / Configuration**.
Look for the **Public IP**. Visit `http://<Public-IP>:8501` to use your agent!
