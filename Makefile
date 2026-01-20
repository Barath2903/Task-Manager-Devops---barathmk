.PHONY: build test clean docker-build docker-push k8s-deploy k8s-delete help

# Variables
DOCKER_REGISTRY ?= localhost:5000
VERSION ?= latest
K8S_NAMESPACE ?= default

help:
	@echo "Available targets:"
	@echo "  build          - Build all Maven projects"
	@echo "  test           - Run all tests"
	@echo "  clean          - Clean Maven build artifacts"
	@echo "  docker-build   - Build all Docker images"
	@echo "  docker-push    - Push Docker images to registry"
	@echo "  docker-compose - Start services with Docker Compose"
	@echo "  k8s-deploy     - Deploy to Kubernetes"
	@echo "  k8s-delete     - Delete Kubernetes resources"
	@echo "  checkstyle     - Run Checkstyle code analysis"

build:
	mvn clean compile

test:
	mvn clean test

integration-test:
	mvn clean verify

clean:
	mvn clean

checkstyle:
	mvn checkstyle:check

docker-build:
	docker build -t $(DOCKER_REGISTRY)/task-service:$(VERSION) -f task-service/Dockerfile .
	docker build -t $(DOCKER_REGISTRY)/user-service:$(VERSION) -f user-service/Dockerfile .
	docker build -t $(DOCKER_REGISTRY)/api-gateway:$(VERSION) -f api-gateway/Dockerfile .

docker-push: docker-build
	docker push $(DOCKER_REGISTRY)/task-service:$(VERSION)
	docker push $(DOCKER_REGISTRY)/user-service:$(VERSION)
	docker push $(DOCKER_REGISTRY)/api-gateway:$(VERSION)

docker-compose:
	docker-compose up -d

docker-compose-down:
	docker-compose down

k8s-deploy:
	@echo "Deploying to Kubernetes..."
	kubectl apply -f k8s/secrets.yaml
	kubectl apply -f k8s/configmap.yaml
	kubectl apply -f k8s/postgres-task-deployment.yaml
	kubectl apply -f k8s/postgres-user-deployment.yaml
	export DOCKER_REGISTRY=$(DOCKER_REGISTRY) && \
	export VERSION=$(VERSION) && \
	envsubst < k8s/task-service-deployment.yaml | kubectl apply -f - && \
	envsubst < k8s/user-service-deployment.yaml | kubectl apply -f - && \
	envsubst < k8s/api-gateway-deployment.yaml | kubectl apply -f -

k8s-delete:
	kubectl delete -f k8s/api-gateway-deployment.yaml || true
	kubectl delete -f k8s/user-service-deployment.yaml || true
	kubectl delete -f k8s/task-service-deployment.yaml || true
	kubectl delete -f k8s/postgres-user-deployment.yaml || true
	kubectl delete -f k8s/postgres-task-deployment.yaml || true
	kubectl delete -f k8s/configmap.yaml || true
	kubectl delete -f k8s/secrets.yaml || true

k8s-status:
	kubectl get pods
	kubectl get services
