# Platform Service

A production-ready containerized microservice built with Flask, Docker, Terraform, and GitHub Actions.

## Features

- ✅ Stateless REST API with structured JSON logging
- ✅ Multi-stage Docker build (security & performance optimized)
- ✅ Infrastructure as Code with Terraform (GCP Cloud Run)
- ✅ Automated CI/CD pipeline with GitHub Actions
- ✅ Complete test suite with coverage reporting
- ✅ Dev/Prod environment separation & scaling

---

## Quick Start

### Prerequisites

- Python 3.11+
- Docker & Docker Compose
- Terraform >= 1.0
- gcloud CLI
- Git

### How to Run Locally

#### Option 1: Native Python

```bash
pip install -r requirements.txt
export COMMIT_SHA=$(git rev-parse HEAD)
export SERVICE_NAME=platform-service
export ENVIRONMENT=development
export PORT=8080
python app/main.py

# Test in another terminal
curl http://localhost:8080/health
curl http://localhost:8080/version
```

#### Option 2: Docker Compose (Recommended)
```bash
docker-compose up
curl http://localhost:8080/health
```

#### Option 3: Docker Build & Run

```bash
docker build -t platform-service:local --build-arg COMMIT_SHA=$(git rev-parse HEAD) .
docker run -it --rm -p 8080:8080 platform-service:local
```

---

## Development

### Run Tests

```bash
pip install -r requirements-dev.txt
make test
pytest tests/ -v --cov=app --cov-report=term-missing
```

### Code Quality

```bash
make lint
make format
make help  # Show all available commands
```

---

## API Endpoints

| Endpoint | Method | Response |
|----------|--------|----------|
| `/health` | GET | `{"status": "OK"}` |
| `/` | GET | `Hello Platform` |
| `/version` | GET | `{"build": "...", "service": "...", "stage": "..."}` |

---

## Infrastructure & Terraform

### Terraform Directory Structure

```
terraform/
├── modules/cloud_run/              # Reusable Cloud Run module
│   ├── main.tf                     # Service, IAM, service account
│   ├── variables.tf                # Fully parameterized variables
│   └── outputs.tf                  # Service URL, metadata
├── dev/                            # Development environment
│   ├── main.tf                     # Dev config (0-5 instances)
│   ├── variables.tf                # cpu, memory, scaling, log_level
│   ├── versions.tf                 # Provider versions
│   ├── outputs.tf                  # Dev outputs
│   └── terraform.tfvars.example    # Example configuration
└── prod/                           # Production environment
    ├── main.tf                     # Prod config (1-20 instances)
    ├── variables.tf                # cpu, memory, scaling, log_level
    ├── versions.tf                 # Provider versions
    ├── outputs.tf                  # Prod outputs
    └── terraform.tfvars.example    # Example configuration
```

### How to Run Terraform

#### 1. Authenticate

```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

#### 2. Configure Variables

```bash
# Development
cd terraform/dev
cp terraform.tfvars.example terraform.tfvars
# Edit: project_id, image, region

# Production
cd ../prod
cp terraform.tfvars.example terraform.tfvars
# Edit: project_id, image, region
```

#### 3. Deploy

```bash
# Development
cd terraform/dev
terraform init
terraform plan
terraform apply

# Production
cd ../prod
terraform init
terraform plan
terraform apply

# Get service URL
terraform output service_url
```

#### 4. Validate Locally

```bash
make terraform-validate

# Or manually
cd terraform/dev
terraform init -backend=false
terraform validate
terraform fmt -check -recursive
```

### Terraform Best Practices

✅ **Full Variablization** - All hardcoded values (cpu, memory, instances, log_level) converted to variables
✅ **Modular Design** - Reusable cloud_run module for both environments
✅ **Environment Separation** - Dev (0-5 instances) vs Prod (1-20 instances)
✅ **Least-Privilege IAM** - Service accounts with only logging & metrics roles
✅ **Health Checks** - Liveness & startup probes configured
✅ **Auto-scaling** - Environment-specific scaling policies

---

## CI/CD Pipeline

### How CI Works

#### PR Validation (Triggered on Pull Requests)
```
✓ Run pytest with coverage
✓ Run flake8 linting
✓ Build Docker image (no push)
✓ Validate Terraform (fmt, validate)
✓ Run Terraform plan (dry-run)

Result: Pass/Fail prevents merge if checks fail
```

#### Dev Deployment (Triggered on Push to develop)
```
✓ All tests and linting pass
✓ Build & push Docker image to GHCR
✓ Tag image with commit SHA (immutable)
✓ Scan for vulnerabilities
✓ Run Terraform apply to terraform/dev
✓ Verify service health
✓ Uses GCP_SA_KEY_dev secret for authentication

Result: Automatic deployment to development
```

#### Prod Deployment (Triggered on Push to main)
```
✓ All tests and linting pass
✓ Build & push Docker image to GHCR
✓ Tag image with commit SHA (immutable)
✓ Scan for vulnerabilities
✓ Run Terraform apply to terraform/prod
✓ Verify service health
✓ Uses GCP_SA_KEY_prod secret for authentication

Result: Automatic deployment to production
```

### CI/CD Workflows

**Develop Branch**: Automatic deployment to dev on push (development environment)
**Main Branch**: Automatic deployment to prod on push (production environment)
**Manual Override**: Use workflow_dispatch to manually trigger any environment

---

## GitHub Secrets Setup

### Required Secrets for CI/CD

You must configure two environment-specific GCP service account secrets in GitHub:

#### 1. `GCP_SA_KEY_dev`
- **Purpose**: Google Cloud authentication for development deployments
- **Used by**: Workflow when deploying to `develop` branch → `terraform/dev`
- **Setup**:
  1. Create a GCP service account for dev: `platform-service-dev`
  2. Grant roles: `roles/run.admin`, `roles/iam.serviceAccountUser`
  3. Generate JSON key
  4. GitHub → Settings → Secrets and variables → Actions → New repository secret
  5. Name: `GCP_SA_KEY_dev`
  6. Paste entire JSON key content

#### 2. `GCP_SA_KEY_prod`
- **Purpose**: Google Cloud authentication for production deployments
- **Used by**: Workflow when deploying to `main` branch → `terraform/prod`
- **Setup**:
  1. Create a GCP service account for prod: `platform-service-prod`
  2. Grant roles: `roles/run.admin`, `roles/iam.serviceAccountUser` (with additional audit logging)
  3. Generate JSON key
  4. GitHub → Settings → Secrets and variables → Actions → New repository secret
  5. Name: `GCP_SA_KEY_prod`
  6. Paste entire JSON key content

### Recommended Best Practices

✅ **Separate GCP Projects**: Use different GCP projects for dev and prod
✅ **Minimal Permissions**: Each secret has only required roles
✅ **Key Rotation**: Rotate keys every 90 days
✅ **Audit Logging**: Enable Cloud Audit Logs for prod
✅ **Backup Keys**: Store backup keys securely (not in GitHub)

---

## Branching Strategy & Release Process

### Git Flow Model

```
main (production, auto-deploy)
  ↑
develop (staging)
  ↑
├─ feature/* (individual features)
├─ bugfix/* (bug fixes)
└─ hotfix/* (emergency fixes, direct from main)
```

### Branch Types & Deployment

| Branch | Source | Auto-Deploy | Environment | Secret |
|--------|--------|-------------|-------------|--------|
| `main` | develop | ✅ Yes | Production | `GCP_SA_KEY_prod` |
| `develop` | feature/* | ✅ Yes | Development | `GCP_SA_KEY_dev` |
| `feature/*` | develop | ❌ No | N/A | N/A |
| `bugfix/*` | develop | ❌ No | N/A | N/A |
| `hotfix/*` | main | ✅ Yes | Production | `GCP_SA_KEY_prod` |

### Feature Development Workflow

```bash
git checkout develop
git pull origin develop
git checkout -b feature/my-feature
# ... make changes ...
git commit -m "feat: add new endpoint"
git push origin feature/my-feature
# → Create PR: feature/my-feature → develop
# → CI checks run automatically
# → On merge: develop branch updated
```

### Production Release Workflow

```bash
git checkout main
git pull origin main
git merge --no-ff develop
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin main
git push origin v1.0.0
# → GitHub Actions auto-triggers deploy workflow
# → Builds image: main-<SHA>
# → Deploys to prod via Terraform
# → Verifies service health
```

### Hotfix (Emergency Production Fix)

```bash
git checkout -b hotfix/critical-bug main
# ... make critical fix ...
git commit -m "fix: critical bug"
git push origin hotfix/critical-bug
# → Create PR: hotfix/critical-bug → main
# → Expedited review & merge
# → Auto-deployed to production
# → Also merge back to develop
```

---

## Project Structure

```
.
├── app/
│   ├── __init__.py                # App module exports (gunicorn WSGI)
│   └── main.py                    # Flask routes, logging, shutdown handler
├── tests/
│   ├── __init__.py
│   ├── conftest.py                # Pytest config & environment setup
│   └── test_app.py                # Unit tests with coverage
├── terraform/                     # Infrastructure as Code
│   ├── modules/cloud_run/         # Reusable Cloud Run module
│   ├── dev/                       # Development environment configs
│   └── prod/                      # Production environment configs
├── Dockerfile                     # Multi-stage Docker build
├── docker-compose.yml             # Local dev (with parameterization)
├── Makefile                       # Development commands
├── requirements.txt               # Production dependencies
├── requirements-dev.txt           # Development dependencies
└── README.md
```

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8080` | Server port |
| `SERVICE_NAME` | `platform-service` | Service identifier |
| `ENVIRONMENT` | `development` | Environment (dev/prod) |
| `COMMIT_SHA` | `dev` | Git commit SHA |
| `LOG_LEVEL` | `INFO` | Logging level |

---

## Production Readiness Reflection

### What Was Built

✅ **Complete DevOps Setup**
- Production-grade containerization (multi-stage builds)
- Infrastructure as Code with Terraform (GCP Cloud Run)
- Full CI/CD automation (GitHub Actions)
- Comprehensive testing & code quality
- Environment separation (dev scales to zero)

✅ **Production-Ready Features**

**Security:**
- Non-root Docker user (UID 1000)
- Minimal base image (python:3.11-slim)
- Least-privilege IAM roles
- Health checks (liveness & startup probes)

**Reliability:**
- Structured JSON logging for observability
- Graceful shutdown handling (SIGTERM/SIGINT)
- Proper HTTP error handling
- Auto-scaling per environment
- Health check verification

**Best Practices:**
- Immutable image tagging (by commit SHA)
- Full parameter variablization (no hardcoded values)
- Modular Terraform code (reusable modules)
- Git Flow branching strategy
- Branch protection rules

### Future Enhancements

⚠️ **Monitoring & Observability**
- Datadog/Prometheus metrics & dashboards
- Distributed tracing (OpenTelemetry)
- SLO definitions & error budgets
- Automated alerting

⚠️ **Security Hardening**
- Cloud Armor (WAF) for DDoS protection
- API authentication (OAuth2/JWT)
- Secrets management (Google Secret Manager)
- VPC for network isolation

⚠️ **Infrastructure Scaling**
- Remote Terraform state (GCS backend)
- Multi-region deployment
- Blue-green/canary deployments
- Disaster recovery procedures

---

## Time Spent

| Component | Time | Notes |
|-----------|------|-------|
| Application (Flask) | 45 min | Routes, JSON logging, graceful shutdown |
| Docker (multi-stage) | 30 min | Builder + runtime stages, non-root user |
| Terraform (dev/prod) | 120 min | Modules, IAM, Cloud Run, variablization |
| GitHub Actions (CI/CD) | 90 min | PR checks, deploy workflow, scanning |
| Testing & validation | 45 min | Unit tests, integration, Docker testing |
| Code review & refactoring | 60 min | Fix tests, entry points, parameterize values |
| Documentation & README | 90 min | Setup guides, CI/CD, branching strategy |
| **Total** | **~480 min (8 hrs)** | Production-ready codebase |

---

## Tradeoffs Made

### 1. Simplicity vs. Enterprise Features
**Decision**: Focus on core patterns, not enterprise complexity
- Minimal infrastructure vs. full enterprise setup (VPC, secrets, multi-region)
- Rationale: Demonstrates best practices without over-engineering

### 2. Python Flask vs. Go/Rust
**Decision**: Python for readability and accessibility
- Slower but more understandable vs. high performance
- Flask can handle 1000s req/sec with gunicorn; sufficient for demo

### 3. GCP Cloud Run vs. Kubernetes
**Decision**: Managed service over full container control
- Simplicity vs. full orchestration capabilities
- Cloud Run scales to zero for dev; perfect for microservices

### 4. Local Terraform State vs. Remote
**Decision**: Local state for demonstration
- Simplicity vs. team collaboration
- Production should use GCS bucket or Terraform Cloud

### 5. Single Region Deployment
**Decision**: Single region (us-central1) over multi-region
- Simplicity vs. high availability
- Future: Add multi-region with Traffic Director

### 6. No API Authentication
**Decision**: Public endpoints (no auth)
- Accessibility vs. security
- Focuses on infrastructure; auth is orthogonal concern

### 7. Minimal Monitoring
**Decision**: Cloud Run built-in metrics only
- Simplicity vs. production observability
- Demonstrates importance of monitoring

### 8. Git Flow vs. Trunk-Based
**Decision**: Git Flow for explicit workflows
- Multi-branch vs. simple main-only
- Better for 5-50 engineers; scales to 100+ with trunk-based

---

## Docker Details

### Multi-stage Build

**Stage 1 (Builder)**
- Installs Python dependencies
- Keeps intermediate build layers

**Stage 2 (Runtime)**
- Minimal footprint (only runtime deps)
- Non-root user (appuser, UID 1000)
- Python 3.11-slim base
- Final size: ~150-200MB vs 500MB+ with deps

### Health Checks

- **Startup Probe**: 5s delay, 10s period, 3s timeout
- **Liveness Probe**: 10s delay, 30s period, 5s timeout
- **Failure Threshold**: 3 consecutive failures triggers restart

---

## Troubleshooting

### Tests Failing
```bash
rm -rf .pytest_cache __pycache__
pip install -r requirements-dev.txt
pytest tests/ -v
```

### Docker Issues
```bash
docker system prune -a
docker build --no-cache -t platform-service:local .
```

### Terraform Errors
```bash
cd terraform/dev
terraform validate
terraform fmt -recursive
terraform plan
```

### GCP Authentication
```bash
gcloud auth application-default login
gcloud config get-value project
```

---

## Contributing

1. Create feature branch from `develop`
2. Make changes and write tests
3. Run `make test` and `make lint`
4. Commit with descriptive messages
5. Create PR to `develop`
6. Merge to `main` for production deployment

---

## License

This project is provided as-is for deployment demonstration purposes.

---

## Support

For issues:
- Check logs: `docker logs platform-service-local`
- Validate: `make terraform-validate`
- Test: `make test`
