# CI/CD Pipeline Overview

## Pipeline Stages

### 1. Build & Test Stage
**Trigger:** Push to `main`/`develop` or Pull Request

**Steps:**
- ✅ Checkout code
- ✅ Set up JDK 17
- ✅ Cache Maven dependencies
- ✅ Run Checkstyle (static code analysis)
- ✅ Compile code with Maven
- ✅ Run unit tests (JUnit 5)
- ✅ Run integration tests (Testcontainers)
- ✅ Generate test reports
- ✅ SonarQube code quality scan (if configured)
- ✅ Build JAR artifacts
- ✅ Upload JARs to Nexus/Artifactory (if configured)

**Artifacts:**
- Compiled JAR files for each service
- Test reports
- Code quality reports

### 2. Docker Build & Push Stage
**Trigger:** After successful build-and-test

**Steps:**
- ✅ Build Docker images for each service (task-service, user-service, api-gateway)
- ✅ Tag images with version (Git SHA or release tag)
- ✅ Push to Docker registry
- ✅ Push to Nexus/Artifactory Docker registry (if configured)
- ✅ Cache Docker layers for faster builds

**Artifacts:**
- Docker images tagged with version
- Latest tag for each service

### 3. Kubernetes Deployment Stage
**Trigger:** Push to `main` branch or release tag

**Steps:**
- ✅ Set up kubectl
- ✅ Set up Minikube (or connect to existing cluster)
- ✅ Apply Kubernetes secrets
- ✅ Apply ConfigMaps
- ✅ Deploy PostgreSQL databases
- ✅ Deploy microservices (task-service, user-service, api-gateway)
- ✅ Wait for deployments to be ready
- ✅ Verify health checks

**Resources Created:**
- PersistentVolumeClaims for databases
- Deployments (2 replicas each)
- Services (ClusterIP and LoadBalancer)
- Secrets and ConfigMaps

### 4. Release Management Stage
**Trigger:** GitHub release creation

**Steps:**
- ✅ Extract version from Git tag
- ✅ Generate release notes from commits
- ✅ Update GitHub release with notes
- ✅ Tag Docker images with release version

**Output:**
- Release notes in Markdown format
- Updated GitHub release page

## Pipeline Configuration

### Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `DOCKER_REGISTRY` | Docker registry URL | Yes | `localhost:5000` |
| `NEXUS_URL` | Nexus/Artifactory URL | No | - |
| `NEXUS_USERNAME` | Nexus username | No | - |
| `NEXUS_PASSWORD` | Nexus password | No | - |
| `SONAR_TOKEN` | SonarQube token | No | - |
| `SONAR_HOST_URL` | SonarQube server URL | No | `http://localhost:9000` |

### GitHub Secrets Required

1. **DOCKER_REGISTRY** - Your Docker registry (e.g., `docker.io`, `ghcr.io`, `registry.example.com`)
2. **DOCKER_USERNAME** - Docker registry username
3. **DOCKER_PASSWORD** - Docker registry password/token
4. **NEXUS_URL** - Nexus/Artifactory URL (optional)
5. **NEXUS_USERNAME** - Nexus username (optional)
6. **NEXUS_PASSWORD** - Nexus password (optional)
7. **SONAR_TOKEN** - SonarQube authentication token (optional)
8. **SONAR_HOST_URL** - SonarQube server URL (optional)

## Versioning Strategy

### Development Versions
- Uses Git SHA as version tag
- Format: `<git-sha>` (e.g., `a1b2c3d4`)

### Release Versions
- Uses Git tag as version
- Format: `v<major>.<minor>.<patch>` (e.g., `v1.0.0`)
- Semantic versioning recommended

### Creating a Release

```bash
# 1. Create and push tag
./scripts/release.sh 1.0.0 "Release version 1.0.0"
git push origin main
git push origin v1.0.0

# 2. Create GitHub release with same tag
# This triggers the release-management job
```

## Artifact Management

### Maven Artifacts (JARs)
- **Location:** Nexus/Artifactory Maven repository
- **Group ID:** `com.taskmanager`
- **Artifact IDs:** `task-service`, `user-service`, `api-gateway`
- **Format:** `jar`

### Docker Images
- **Registry:** Configured via `DOCKER_REGISTRY`
- **Repositories:** 
  - `task-service`
  - `user-service`
  - `api-gateway`
- **Tags:** Version (SHA or tag) + `latest`

## Deployment Strategy

### Development Environment
- Automatic deployment on push to `develop` branch
- Uses latest Docker images
- Single replica per service

### Production Environment
- Deployment triggered by release tags
- Uses versioned Docker images
- 2 replicas per service for high availability
- Health checks and readiness probes configured

## Monitoring & Health Checks

All services include Spring Boot Actuator endpoints:
- **Health:** `/actuator/health`
- **Info:** `/actuator/info`

Kubernetes probes configured:
- **Liveness Probe:** Checks if service is alive
- **Readiness Probe:** Checks if service is ready to accept traffic

## Pipeline Optimization

### Caching
- Maven dependencies cached between runs
- Docker layers cached in registry
- Build context optimized with `.dockerignore`

### Parallel Execution
- Docker builds run in parallel (matrix strategy)
- Services can be deployed in parallel

### Conditional Execution
- Docker push skipped on pull requests
- Kubernetes deployment only on main branch or releases
- SonarQube scan only if token is configured

## Troubleshooting

### Build Failures
1. Check Maven compilation errors
2. Verify test failures
3. Review Checkstyle violations
4. Check SonarQube quality gates

### Docker Build Failures
1. Verify Dockerfile syntax
2. Check build context
3. Ensure base images are accessible
4. Review Docker registry credentials

### Deployment Failures
1. Check Kubernetes cluster connectivity
2. Verify image pull secrets
3. Review pod logs: `kubectl logs <pod-name>`
4. Check resource limits and requests
5. Verify database connectivity

### Release Failures
1. Ensure Git tag exists
2. Verify GitHub release exists
3. Check release notes generation script
4. Review GitHub API permissions

## Next Steps

1. **Configure Secrets:** Set up all required GitHub secrets
2. **Set up Nexus/Artifactory:** Configure artifact repository
3. **Configure SonarQube:** Set up code quality analysis
4. **Set up Monitoring:** Add Prometheus/Grafana
5. **Configure Notifications:** Add Slack/Email notifications
6. **Set up Staging Environment:** Create separate deployment for staging
7. **Add Security Scanning:** Integrate vulnerability scanners
8. **Performance Testing:** Add load testing in pipeline
