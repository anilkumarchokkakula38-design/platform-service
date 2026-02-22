.PHONY: help install install-dev test lint format docker-build docker-run clean terraform-validate terraform-plan terraform-apply docker-compose-up docker-compose-down

help:
	@echo "Platform Service - Development Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make install          Install production dependencies"
	@echo "  make install-dev      Install development dependencies"
	@echo ""
	@echo "Testing & Validation:"
	@echo "  make test             Run unit tests"
	@echo "  make lint             Run linting checks"
	@echo "  make format           Auto-format code"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-build     Build Docker image"
	@echo "  make docker-run       Run Docker image locally"
	@echo "  make docker-compose-up    Run with docker-compose"
	@echo "  make docker-compose-down  Stop docker-compose"
	@echo ""
	@echo "Infrastructure:"
	@echo "  make terraform-validate   Validate Terraform"
	@echo "  make terraform-plan       Plan Terraform (dev)"
	@echo "  make terraform-apply      Apply Terraform (dev)"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean            Remove temporary files"

install:
	pip install -r requirements.txt

install-dev: install
	pip install -r requirements-dev.txt

test: install-dev
	pytest tests/ -v --cov=app --cov-report=term-missing --cov-report=html

lint: install-dev
	flake8 app tests --max-line-length=127 --count --statistics

format:
	black app tests --line-length=127 || true
	isort app tests || true

docker-build:
	docker build -t platform-service:local \
		--build-arg COMMIT_SHA=$$(git rev-parse HEAD) .

docker-run: docker-build
	docker run -it --rm \
		-p 8080:8080 \
		-e COMMIT_SHA=$$(git rev-parse HEAD) \
		-e SERVICE_NAME=platform-service \
		-e ENVIRONMENT=development \
		platform-service:local

docker-compose-up:
	docker-compose up -d
	@echo "Service running at http://localhost:8080"

docker-compose-down:
	docker-compose down

terraform-validate:
	@echo "Validating Terraform configuration..."
	cd terraform/dev && terraform init -backend=false && terraform validate && terraform fmt -check -recursive
	cd ../../terraform/prod && terraform init -backend=false && terraform validate && terraform fmt -check -recursive

terraform-plan:
	cd terraform/dev && terraform init && terraform plan

terraform-apply:
	cd terraform/dev && terraform init && terraform apply

clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache .coverage htmlcov build dist *.egg-info
	rm -rf terraform/dev/.terraform terraform/prod/.terraform
	rm -f terraform/dev/.terraform.lock.hcl terraform/prod/.terraform.lock.hcl
