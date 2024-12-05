.PHONY: env install clean dev build docker-build docker-run deploy release help
.DEFAULT_GOAL := help 

# Check for .env file and load variables
ifeq (,$(wildcard .env))
$(error .env file not found. Please run 'cp .env.example .env' first)
endif

# Load environment variables
include .env
export

# Debug environment variables
env:
	@clear
	env
	
# Cleanup
clean:
	@clear
	kubectl delete namespace $(APP_PROJECT_NAME) 2>/dev/null || true
	docker rmi $(APP_REGISTRY)/$(APP_PROJECT_NAME):latest 2>/dev/null || true
	rm -rf node_modules .next venv
	find . -type d -name __pycache__ -exec rm -rf {} +

# Install dependencies
install:
	@clear
	npm install
	python3 -m venv venv
	pip install --upgrade pip
	. venv/bin/activate && pip install -r requirements.txt

# Development
dev:
	@clear
	npx concurrently \
		"npm run next-dev" \
		". venv/bin/activate && python3 -m uvicorn api.index:app --reload --host 127.0.0.1 --port 8000"

# Build
build:
	source .env 
	npm run build

# Build and push Docker image
docker-build:
	@clear
	docker rmi $(APP_PROJECT_NAME):latest 2>/dev/null || true
	docker rmi $(APP_REGISTRY)/$(APP_PROJECT_NAME):latest 2>/dev/null || true
	docker build --no-cache --build-arg APP_PROJECT_NAME=$(APP_PROJECT_NAME) -t $(APP_PROJECT_NAME):latest -t $(APP_REGISTRY)/$(APP_PROJECT_NAME):latest .
	docker login $(APP_REGISTRY) -u $(APP_DOCKER_USERNAME) -p $(APP_DOCKER_PASSWORD)
	docker push $(APP_REGISTRY)/$(APP_PROJECT_NAME):latest

# Run in docker
docker-run:
	@clear
	docker run \
		-p 3000:3000 \
		-e NODE_ENV="development" \
		-e NEXT_SHARP_PATH="/app/node_modules/sharp" \
		-e NODE_OPTIONS="--enable-source-maps --trace-warnings" \
		-e NEXT_TELEMETRY_DEBUG="1" \
		-e APP_PROJECT_NAME=$(APP_PROJECT_NAME) \
		-e APP_OLLAMA_HOST="${APP_OLLAMA_HOST}" \
		-e APP_OLLAMA_PORT="${APP_OLLAMA_PORT}" \
		-e APP_OLLAMA_MODEL="${APP_OLLAMA_MODEL}" \
		$(APP_PROJECT_NAME):latest

# Deployment
deploy:
	@clear
	@echo "\nDeploying to Kubernetes"
	@echo "==========================="
	kubectl delete namespace $(APP_PROJECT_NAME) 2>/dev/null || true
	kubectl create namespace $(APP_PROJECT_NAME) 2>/dev/null || true
	
	@echo "\nCreating registry secret...\n"
	@echo "================================"
	@echo '{"auths":{"$(APP_REGISTRY)":{"username":"$(APP_DOCKER_USERNAME)","password":"$(APP_DOCKER_PASSWORD)"}}}' > /tmp/dockerconfigjson
	kubectl create secret generic regcred \
		--namespace=$(APP_PROJECT_NAME) \
		--from-file=.dockerconfigjson=/tmp/dockerconfigjson \
		--type=kubernetes.io/dockerconfigjson \
		--dry-run=client -o yaml | kubectl apply -f -
	rm /tmp/dockerconfigjson
		
	@echo "\nApplying Kubernetes manifests...\n"
	@echo "================================"
	@for file in k8s/*.yaml; do \
		echo "\n=== Applying $$file... =======================\n"; \
		envsubst < $$file | kubectl apply -f -; \
	done
	
	@echo "\nWaiting for deployment..."
	@echo "============================\n"
	kubectl wait --for=condition=ready pod -l app=$(APP_PROJECT_NAME) -n $(APP_PROJECT_NAME) --timeout=120s
	@echo "Deployment complete. Pod status:"
	kubectl get pods -n $(APP_PROJECT_NAME)

# Release
release: docker-build deploy

# Help
help:
	@clear
	@echo "Available commands:"
	@echo "  make install  	- Install all dependencies"
	@echo "  make dev      	- Start development servers"
	@echo "  make build    	- Build"
	@echo "  make docker-build	- Build and push Docker image"
	@echo "  make docker-run  	- Run Docker image"
	@echo "  make deploy   	- Deploy to Kubernetes"
	@echo "  make release  	- Build and Deploy"
	@echo "  make clean    	- Remove all resources"
	@echo "  make env      	- Show environment variables"

