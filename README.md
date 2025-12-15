# thrivecart-test-serverless

# Serverless Health Check API with CI/CD

This repository contains a serverless health check API deployed on AWS using Terraform for infrastructure management and GitHub Actions for CI/CD automation. The application exposes a `/health` endpoint that logs incoming requests and stores them in DynamoDB.

## Architecture

- **API Gateway (HTTP API)**: Exposes the `/health` endpoint (supports GET and POST)
- **AWS Lambda (Python)**: Processes requests, logs to CloudWatch, and saves to DynamoDB
- **Amazon DynamoDB**: Stores request payloads with unique IDs
- **Terraform**: Manages all AWS infrastructure as code
- **GitHub Actions**: Automates CI/CD pipeline for staging and production deployments

## Repository Structure

```
.
├── lambda/
│   └── app.py                 # Lambda function source code
├── modules/
│   ├── dynamodb/              # DynamoDB table module
│   ├── iam/                   # IAM role module for Lambda
│   ├── lambda/                # Lambda function module
│   └── apigateway/            # API Gateway module
├── project/
│   ├── main.tf                # Main Terraform configuration
│   ├── variables.tf           # Variable definitions
│   ├── outputs.tf             # Output values
│   ├── terraform.tf           # Backend and provider configuration
│   ├── local.tf               # Local values and tags
│   ├── staging.tfvars         # Staging environment variables
│   └── prod.tfvars            # Production environment variables
├── .github/
│   └── workflows/
│       └── deploy.yml         # GitHub Actions CI/CD pipeline
└── README.md
```

## Resource Naming Convention

All AWS resources follow the naming convention: `env-resource-name`

Examples:
- `staging-requests-db` (DynamoDB table)
- `staging-health-check-function` (Lambda function)
- `staging-health-api` (API Gateway)
- `staging-lambda-role` (IAM role)

## Prerequisites

To run or deploy this project, you need:

1. **AWS Account** with appropriate permissions for:
   - Lambda
   - API Gateway
   - DynamoDB
   - IAM
   - S3 (for Terraform state storage)
   - CloudWatch Logs

2. **Terraform** >= 1.5.0 installed locally (for manual deployments)

3. **Python** 3.12 (for Lambda function)

4. **GitHub Repository Secrets** (configured in GitHub repository settings):
   - `AWS_ACCESS_KEY_ID`: AWS access key ID
   - `AWS_SECRET_ACCESS_KEY`: AWS secret access key

5. **Terraform Backend Configuration**:
   - S3 bucket: `thrivecart-terraform-state-bucket` (must exist in eu-west-1)
   - DynamoDB table for state locking (optional but recommended)

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/deploy.yml`) automates the deployment process using Terraform workspaces for environment isolation.

### Pipeline Flow

1. **Trigger**: Pipeline runs on push to `main` branch or manual workflow dispatch

2. **Deploy Staging** (Automatic):
   - Checks out code
   - Packages the Lambda function (`app.py`) into `lambda.zip`
   - Configures AWS credentials
   - Initializes Terraform
   - Selects or creates the `staging` workspace
   - Applies changes automatically using `staging.tfvars`

3. **Plan Production** (Automatic):
   - Runs in parallel with staging deployment
   - Checks out code
   - Packages the Lambda function
   - Configures AWS credentials
   - Initializes Terraform
   - Selects or creates the `production` workspace
   - Creates a Terraform plan using `prod.tfvars`
   - Uploads the plan file as an artifact

4. **Apply Production** (Requires Manual Approval):
   - Waits for manual approval via GitHub Environments
   - Downloads the plan file from the plan job
   - Applies the approved plan to production

### Manual Approval for Production

Production deployments require manual approval through GitHub Environments. To configure:

1. Go to your GitHub repository
2. Navigate to **Settings** → **Environments**
3. Click **New environment** and name it `production`
4. Under **Required reviewers**, add the users or teams who should approve production deployments
5. Optionally configure deployment branches and protection rules
6. Click **Save protection rules**

Once configured, when the workflow reaches the `apply-production` job, it will pause and wait for approval. Reviewers can review the Terraform plan output from the `plan-production` job before approving. An approval request will be sent to the configured reviewers, who can approve or reject the deployment from the GitHub Actions UI.

## How to Trigger a Deployment for Staging

### Option 1: Automatic Deployment (Recommended)

1. Push changes to the `main` branch:
   ```bash
   git add .
   git commit -m "Update infrastructure"
   git push origin main
   ```

2. The GitHub Actions workflow will automatically:
   - Package the Lambda function
   - Deploy to staging environment (using staging workspace)
   - Plan production deployment (using production workspace)
   - Wait for manual approval before applying to production

### Option 2: Manual Workflow Dispatch

1. Go to the GitHub repository
2. Navigate to Actions tab
3. Select "Deploy Infrastructure" workflow
4. Click "Run workflow"
5. Select the branch (usually `main`)
6. Click "Run workflow"

### Option 3: Local Deployment

1. Package the Lambda function:
   ```bash
   cd lambda
   zip lambda.zip app.py
   cd ..
   ```

2. Navigate to the project directory:
   ```bash
   cd project
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Select or create the workspace:
   ```bash
   # For staging
   terraform workspace select staging || terraform workspace new staging
   
   # For production
   terraform workspace select production || terraform workspace new production
   ```

5. Plan the deployment:
   ```bash
   # For staging
   terraform plan -var-file="staging.tfvars"
   
   # For production
   terraform plan -var-file="prod.tfvars"
   ```

6. Apply the changes:
   ```bash
   # For staging
   terraform apply -var-file="staging.tfvars"
   
   # For production
   terraform apply -var-file="prod.tfvars"
   ```

## Testing the API

After deployment, you can test the `/health` endpoint using curl (both GET and POST are supported):

### Get the API Endpoint

The API endpoint URL is available in Terraform outputs. Make sure you're in the correct workspace:

```bash
cd project
# For staging endpoint
terraform workspace select staging
terraform output api_endpoint

# For production endpoint
terraform workspace select production
terraform output api_endpoint
```

Or check the GitHub Actions workflow output after deployment.

### Test with GET Request

```bash
curl https://<api-id>.execute-api.eu-west-1.amazonaws.com/health
```

### Test with POST Request

```bash
curl -X POST https://<api-id>.execute-api.eu-west-1.amazonaws.com/health \
  -H "Content-Type: application/json" \
  -d '{"test": "value"}'
```

### Expected Response

```json
{
  "status": "healthy",
  "message": "Request processed and saved.",
  "id": "unique-request-id"
}
```

## Design Choices and Assumptions

1. **Naming Convention**: Resources use `env-resource-name` format as specified in requirements, ensuring clear environment identification and cost attribution.

2. **HTTP API Gateway**: Chose HTTP API over REST API for simplicity, lower cost, and better performance for this use case.

3. **Terraform Modules**: Structured infrastructure using reusable modules (dynamodb, iam, lambda, apigateway) for maintainability and reusability across environments.

4. **Environment Variables**: Each environment (staging/production) uses separate `.tfvars` files to manage environment-specific configurations.

5. **Lambda Versioning**: Lambda functions are published with versions and aliases for safe rollbacks and environment-specific deployments.

6. **Least Privilege IAM**: Lambda IAM role has minimal permissions - only CloudWatch Logs write access (scoped to log groups) and DynamoDB `PutItem` permission for the specific table.

7. **DynamoDB Pay-per-Request**: Used on-demand billing mode for simplicity and cost-effectiveness at low traffic volumes.

8. **Terraform Workspaces**: Uses Terraform workspaces (`staging` and `production`) to manage separate state files for each environment within the same S3 backend. This provides environment isolation while using a single backend configuration.

9. **CI/CD Automation**: 
   - Staging deploys automatically on push to main
   - Production planning runs automatically to generate a plan for review
   - Production apply requires manual approval to enforce safe promotion practices
   - The approval step allows reviewers to examine the Terraform plan before approving the deployment

10. **HTTP Method Support**: The `/health` endpoint accepts both GET and POST requests.

## Troubleshooting

### Lambda Package Not Found

Ensure the `lambda.zip` file exists in the `lambda/` directory before running Terraform. The GitHub Actions workflow creates this automatically, but for local deployments, you must create it manually:

```bash
cd lambda
zip lambda.zip app.py
```

The package must be created in the `lambda/` directory (not in the parent directory).

### Terraform Backend Errors

If you encounter backend errors, ensure:
- The S3 bucket `thrivecart-terraform-state-bucket` exists in `eu-west-1`
- Your AWS credentials have permissions to read/write to the bucket
- The bucket has versioning enabled (recommended)
- Workspaces are properly selected before running plan/apply commands

### API Gateway Not Invoking Lambda

Check that:
- Lambda permissions allow API Gateway to invoke the function
- The integration is correctly configured
- The `/health` routes (GET and POST) are set up correctly

## License

This project is provided as-is for assessment purposes.
