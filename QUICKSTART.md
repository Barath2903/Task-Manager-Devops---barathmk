# Quick Start Guide

## Prerequisites Check

```bash
# Check Java version (should be 17+)
java -version

# Check Maven version (should be 3.8+)
mvn -version

# Check Docker
docker --version
docker-compose --version

# Check Kubernetes (optional)
kubectl version --client
minikube version
```

## Local Development - Quick Start

### Option 1: Docker Compose (Recommended)

```bash
# Start all services
docker-compose up -d

# Check logs
docker-compose logs -f

# Test the API
curl http://localhost:8080/api/tasks
curl http://localhost:8080/api/users

# Stop services
docker-compose down
```

### Option 2: Manual Setup

1. **Start Databases:**
```bash
docker run -d --name postgres-task \
  -e POSTGRES_DB=taskdb \
  -e POSTGRES_USER=taskuser \
  -e POSTGRES_PASSWORD=taskpass \
  -p 5432:5432 \
  postgres:15-alpine

docker run -d --name postgres-user \
  -e POSTGRES_DB=userdb \
  -e POSTGRES_USER=useruser \
  -e POSTGRES_PASSWORD=userpass \
  -p 5433:5432 \
  postgres:15-alpine
```

2. **Build and Run:**
```bash
# Build all modules
mvn clean install

# Run Task Service (Terminal 1)
cd task-service && mvn spring-boot:run

# Run User Service (Terminal 2)
cd user-service && mvn spring-boot:run

# Run API Gateway (Terminal 3)
cd api-gateway && mvn spring-boot:run
```

## Testing

```bash
# Run all tests
mvn test

# Run with integration tests
mvn verify

# Run Checkstyle
mvn checkstyle:check

# Run specific module tests
cd task-service && mvn test
```

## Building Docker Images

```bash
# Build all images
make docker-build

# Or manually
docker build -t task-service:latest -f task-service/Dockerfile .
docker build -t user-service:latest -f user-service/Dockerfile .
docker build -t api-gateway:latest -f api-gateway/Dockerfile .
```

## Kubernetes Deployment

### Using Minikube

```bash
# Start Minikube
minikube start

# Deploy
export DOCKER_REGISTRY=localhost:5000
export VERSION=latest
make k8s-deploy

# Check status
make k8s-status

# Access API Gateway
minikube service api-gateway

# Cleanup
make k8s-delete
```

## API Testing Examples

### Create a User
```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "name": "John Doe"
  }'
```

### Create a Task
```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Complete project",
    "description": "Finish the task manager project",
    "userId": 1,
    "status": "PENDING"
  }'
```

### Get All Tasks
```bash
curl http://localhost:8080/api/tasks
```

### Get Tasks by User
```bash
curl http://localhost:8080/api/tasks?userId=1
```

## CI/CD Setup

1. **Fork or clone the repository**

2. **Set up GitHub Secrets:**
   - Go to Settings → Secrets and variables → Actions
   - Add the following secrets:
     - `DOCKER_REGISTRY` - Your Docker registry URL
     - `DOCKER_USERNAME` - Docker registry username
     - `DOCKER_PASSWORD` - Docker registry password
     - `NEXUS_URL` - Nexus/Artifactory URL (optional)
     - `NEXUS_USERNAME` - Nexus username (optional)
     - `NEXUS_PASSWORD` - Nexus password (optional)
     - `SONAR_TOKEN` - SonarQube token (optional)
     - `SONAR_HOST_URL` - SonarQube server URL (optional)

3. **Push to trigger pipeline:**
```bash
git push origin main
```

4. **Create a release:**
```bash
./scripts/release.sh 1.0.0 "Initial release"
git push origin main
git push origin v1.0.0
```

## Troubleshooting

### Port Already in Use
```bash
# Find process using port
lsof -i :8080
lsof -i :8081
lsof -i :8082

# Kill process
kill -9 <PID>
```

### Docker Build Fails
- Ensure Docker daemon is running
- Check Dockerfile paths are correct
- Verify Maven dependencies are available

### Kubernetes Deployment Issues
- Check Minikube is running: `minikube status`
- Verify images are available: `kubectl get pods`
- Check logs: `kubectl logs <pod-name>`

### Database Connection Issues
- Verify PostgreSQL containers are running
- Check connection strings in application.yml
- Ensure network connectivity between services

## Next Steps

1. Review the [README.md](README.md) for detailed documentation
2. Check [HELM_CHART.md](HELM_CHART.md) for Helm deployment options
3. Customize the CI/CD pipeline in `.github/workflows/ci-cd-pipeline.yml`
4. Configure your artifact repository (Nexus/Artifactory)
5. Set up monitoring and logging (Prometheus, Grafana, ELK)
