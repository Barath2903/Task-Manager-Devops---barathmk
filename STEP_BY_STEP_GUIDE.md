# Step-by-Step Guide to Run Task Manager Project

## Prerequisites Installation

### Step 1: Install Java 17

**macOS (using Homebrew):**
```bash
brew install openjdk@17
echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
java -version  # Should show version 17
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install openjdk-17-jdk
java -version  # Should show version 17
```

**Windows:**
1. Download JDK 17 from: https://adoptium.net/
2. Install and set JAVA_HOME environment variable
3. Add Java to PATH

### Step 2: Install Maven

**macOS:**
```bash
brew install maven
mvn -version  # Should show version 3.8+
```

**Linux:**
```bash
sudo apt install maven
mvn -version
```

**Windows:**
1. Download from: https://maven.apache.org/download.cgi
2. Extract and add to PATH

### Step 3: Install Docker

**macOS:**
```bash
# Download Docker Desktop from: https://www.docker.com/products/docker-desktop
# Or using Homebrew:
brew install --cask docker
# Start Docker Desktop application
```

**Linux:**
```bash
sudo apt update
sudo apt install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER  # Log out and back in
```

**Windows:**
1. Download Docker Desktop from: https://www.docker.com/products/docker-desktop
2. Install and start Docker Desktop

**Verify Docker:**
```bash
docker --version
docker-compose --version
docker ps  # Should not error
```

### Step 4: Install Git (if not already installed)

```bash
git --version
# If not installed:
# macOS: brew install git
# Linux: sudo apt install git
```

---

## Option A: Running with Docker Compose (Easiest Method)

### Step 1: Navigate to Project Directory

```bash
cd "/Users/barath/Task Manager Devops"
# Or wherever you cloned/downloaded the project
```

### Step 2: Build and Start All Services

```bash
# Start all services (databases + microservices)
docker-compose up -d

# Check if all containers are running
docker-compose ps

# You should see:
# - postgres-task (running)
# - postgres-user (running)
# - task-service (running)
# - user-service (running)
# - api-gateway (running)
```

### Step 3: Check Logs

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f task-service
docker-compose logs -f user-service
docker-compose logs -f api-gateway
```

### Step 4: Wait for Services to Start

Wait about 30-60 seconds for all services to fully start. You'll know they're ready when:
- No errors in logs
- Health endpoints respond (see Step 5)

### Step 5: Verify Services are Running

Open a new terminal and test:

```bash
# Test API Gateway health
curl http://localhost:8080/actuator/health

# Test Task Service (direct)
curl http://localhost:8081/actuator/health

# Test User Service (direct)
curl http://localhost:8082/actuator/health
```

### Step 6: Test the API

```bash
# 1. Create a User
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "name": "John Doe"
  }'

# Response should show the created user with an ID

# 2. Get All Users
curl http://localhost:8080/api/users

# 3. Create a Task (use userId from step 1, usually 1)
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Complete project",
    "description": "Finish the task manager project",
    "userId": 1,
    "status": "PENDING"
  }'

# 4. Get All Tasks
curl http://localhost:8080/api/tasks

# 5. Get Tasks by User
curl http://localhost:8080/api/tasks?userId=1
```

### Step 7: Stop Services (when done)

```bash
docker-compose down

# To also remove volumes (clears database data):
docker-compose down -v
```

---

## Option B: Running Manually (For Development)

### Step 1: Start PostgreSQL Databases

```bash
# Start Task Database
docker run -d --name postgres-task \
  -e POSTGRES_DB=taskdb \
  -e POSTGRES_USER=taskuser \
  -e POSTGRES_PASSWORD=taskpass \
  -p 5432:5432 \
  postgres:15-alpine

# Start User Database
docker run -d --name postgres-user \
  -e POSTGRES_DB=userdb \
  -e POSTGRES_USER=useruser \
  -e POSTGRES_PASSWORD=userpass \
  -p 5433:5432 \
  postgres:15-alpine

# Verify databases are running
docker ps | grep postgres
```

### Step 2: Build the Project

```bash
# Navigate to project root
cd "/Users/barath/Task Manager Devops"

# Build all modules (this will download dependencies, compile, and run tests)
mvn clean install

# If tests fail, you can skip them:
# mvn clean install -DskipTests
```

### Step 3: Run Task Service

**Open Terminal 1:**

```bash
cd "/Users/barath/Task Manager Devops/task-service"
mvn spring-boot:run

# Wait for: "Started TaskServiceApplication"
# Service will be available at http://localhost:8081
```

### Step 4: Run User Service

**Open Terminal 2:**

```bash
cd "/Users/barath/Task Manager Devops/user-service"
mvn spring-boot:run

# Wait for: "Started UserServiceApplication"
# Service will be available at http://localhost:8082
```

### Step 5: Run API Gateway

**Open Terminal 3:**

```bash
cd "/Users/barath/Task Manager Devops/api-gateway"
mvn spring-boot:run

# Wait for: "Started ApiGatewayApplication"
# Gateway will be available at http://localhost:8080
```

### Step 6: Test the Services

Use the same curl commands from Option A, Step 6.

### Step 7: Stop Services

Press `Ctrl+C` in each terminal to stop the services.

Clean up databases:
```bash
docker stop postgres-task postgres-user
docker rm postgres-task postgres-user
```

---

## Option C: Running with Kubernetes/Minikube

### Step 1: Install Minikube

**macOS:**
```bash
brew install minikube
```

**Linux:**
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

**Windows:**
Download from: https://minikube.sigs.k8s.io/docs/start/

### Step 2: Install kubectl

**macOS:**
```bash
brew install kubectl
```

**Linux:**
```bash
sudo apt install kubectl
```

**Windows:**
Download from: https://kubernetes.io/docs/tasks/tools/

### Step 3: Start Minikube

```bash
# Start Minikube
minikube start

# Verify
kubectl get nodes
```

### Step 4: Build Docker Images

```bash
# Set Docker to use Minikube's Docker daemon
eval $(minikube docker-env)

# Build images
cd "/Users/barath/Task Manager Devops"
docker build -t task-service:latest -f task-service/Dockerfile .
docker build -t user-service:latest -f user-service/Dockerfile .
docker build -t api-gateway:latest -f api-gateway/Dockerfile .

# Verify images
docker images | grep -E "task-service|user-service|api-gateway"
```

### Step 5: Deploy to Kubernetes

```bash
# Set environment variables
export DOCKER_REGISTRY=localhost:5000
export VERSION=latest

# Apply secrets
kubectl apply -f k8s/secrets.yaml

# Apply configmap
kubectl apply -f k8s/configmap.yaml

# Deploy databases
kubectl apply -f k8s/postgres-task-deployment.yaml
kubectl apply -f k8s/postgres-user-deployment.yaml

# Wait for databases to be ready
kubectl wait --for=condition=available --timeout=60s deployment/postgres-task
kubectl wait --for=condition=available --timeout=60s deployment/postgres-user

# Update deployment files to use local images
# Edit k8s/task-service-deployment.yaml and change image to: task-service:latest
# Edit k8s/user-service-deployment.yaml and change image to: user-service:latest
# Edit k8s/api-gateway-deployment.yaml and change image to: api-gateway:latest

# Deploy services
kubectl apply -f k8s/task-service-deployment.yaml
kubectl apply -f k8s/user-service-deployment.yaml
kubectl apply -f k8s/api-gateway-deployment.yaml
```

### Step 6: Check Deployment Status

```bash
# Check pods
kubectl get pods

# Check services
kubectl get services

# View logs
kubectl logs -f deployment/task-service
kubectl logs -f deployment/user-service
kubectl logs -f deployment/api-gateway
```

### Step 7: Access the API Gateway

```bash
# Get the service URL
minikube service api-gateway --url

# Or port-forward
kubectl port-forward service/api-gateway 8080:80

# Then test:
curl http://localhost:8080/api/users
```

### Step 8: Clean Up Kubernetes

```bash
# Delete all resources
kubectl delete -f k8s/

# Stop Minikube
minikube stop
```

---

## Testing the Application

### Using curl (Command Line)

```bash
# 1. Create User
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "alice",
    "email": "alice@example.com",
    "name": "Alice Smith"
  }'

# 2. Get User by ID
curl http://localhost:8080/api/users/1

# 3. Create Task
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Learn Spring Boot",
    "description": "Complete Spring Boot tutorial",
    "userId": 1,
    "status": "PENDING"
  }'

# 4. Update Task Status
curl -X PUT http://localhost:8080/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Learn Spring Boot",
    "description": "Complete Spring Boot tutorial",
    "userId": 1,
    "status": "IN_PROGRESS"
  }'

# 5. Get All Tasks
curl http://localhost:8080/api/tasks

# 6. Get Tasks by User
curl http://localhost:8080/api/tasks?userId=1

# 7. Delete Task
curl -X DELETE http://localhost:8080/api/tasks/1
```

### Using Postman or Browser

1. **Create User:**
   - Method: POST
   - URL: http://localhost:8080/api/users
   - Headers: Content-Type: application/json
   - Body (JSON):
     ```json
     {
       "username": "bob",
       "email": "bob@example.com",
       "name": "Bob Johnson"
     }
     ```

2. **Get All Users:**
   - Method: GET
   - URL: http://localhost:8080/api/users

3. **Create Task:**
   - Method: POST
   - URL: http://localhost:8080/api/tasks
   - Body (JSON):
     ```json
     {
       "title": "Deploy to production",
       "description": "Deploy the application",
       "userId": 1,
       "status": "PENDING"
     }
     ```

---

## Troubleshooting

### Problem: Port Already in Use

**Solution:**
```bash
# Find process using port
lsof -i :8080
lsof -i :8081
lsof -i :8082

# Kill the process
kill -9 <PID>

# Or change ports in application.yml files
```

### Problem: Docker Containers Won't Start

**Solution:**
```bash
# Check Docker is running
docker ps

# Check logs
docker-compose logs

# Remove and restart
docker-compose down
docker-compose up -d
```

### Problem: Database Connection Failed

**Solution:**
```bash
# Check if PostgreSQL containers are running
docker ps | grep postgres

# Check database logs
docker logs postgres-task
docker logs postgres-user

# Verify connection strings in application.yml
```

### Problem: Maven Build Fails

**Solution:**
```bash
# Clean Maven cache
rm -rf ~/.m2/repository

# Rebuild
mvn clean install

# If still failing, check Java version
java -version  # Should be 17
```

### Problem: Services Can't Connect to Each Other

**Solution:**
- In Docker Compose: Services use service names (task-service, user-service)
- In Manual: Use localhost
- In Kubernetes: Use service names (task-service, user-service)

### Problem: Health Checks Fail

**Solution:**
```bash
# Check if Actuator is enabled
# Verify application.yml has management.endpoints configuration

# Test health endpoint directly
curl http://localhost:8081/actuator/health
```

---

## Quick Reference

### Service URLs

| Service | Direct URL | Through Gateway |
|---------|-----------|-----------------|
| API Gateway | http://localhost:8080 | - |
| Task Service | http://localhost:8081 | http://localhost:8080/api/tasks |
| User Service | http://localhost:8082 | http://localhost:8080/api/users |

### Database Ports

| Database | Port | Connection String |
|----------|------|-------------------|
| Task DB | 5432 | jdbc:postgresql://localhost:5432/taskdb |
| User DB | 5433 | jdbc:postgresql://localhost:5433/userdb |

### Useful Commands

```bash
# Docker Compose
docker-compose up -d          # Start all services
docker-compose down           # Stop all services
docker-compose logs -f        # View logs
docker-compose ps             # Check status

# Maven
mvn clean install             # Build project
mvn test                      # Run tests
mvn spring-boot:run           # Run service

# Kubernetes
kubectl get pods              # List pods
kubectl get services          # List services
kubectl logs <pod-name>       # View logs
kubectl describe pod <pod>    # Pod details
```

---

## Next Steps After Running

1. **Explore the API:** Try all CRUD operations
2. **Check Logs:** Monitor service logs for activity
3. **Run Tests:** Execute `mvn test` to see unit tests
4. **Modify Code:** Make changes and see them reflected
5. **Deploy to Cloud:** Use the Kubernetes manifests for cloud deployment

---

## Need Help?

- Check logs: `docker-compose logs` or `kubectl logs`
- Verify services: `docker-compose ps` or `kubectl get pods`
- Test endpoints: Use curl or Postman
- Review configuration: Check `application.yml` files
