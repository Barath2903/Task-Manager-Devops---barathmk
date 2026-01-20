# Helm Chart (Optional)

This document describes how to use Helm charts for deploying the Task Manager microservices.

## Prerequisites

- Helm 3.x installed
- Kubernetes cluster access
- Docker registry credentials configured

## Installation

### Create Helm Chart Structure

```bash
helm create task-manager
```

### Example values.yaml

```yaml
replicaCount: 2

image:
  registry: localhost:5000
  pullPolicy: Always

taskService:
  image:
    repository: task-service
    tag: latest
  service:
    port: 8081
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi

userService:
  image:
    repository: user-service
    tag: latest
  service:
    port: 8082
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi

apiGateway:
  image:
    repository: api-gateway
    tag: latest
  service:
    type: LoadBalancer
    port: 80
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi

postgres:
  task:
    enabled: true
    database: taskdb
    username: taskuser
    password: taskpass
  user:
    enabled: true
    database: userdb
    username: useruser
    password: userpass
```

### Deploy with Helm

```bash
# Install
helm install task-manager ./helm/task-manager -f ./helm/task-manager/values.yaml

# Upgrade
helm upgrade task-manager ./helm/task-manager -f ./helm/task-manager/values.yaml

# Uninstall
helm uninstall task-manager
```

## Integration with CI/CD

Update the GitHub Actions workflow to use Helm:

```yaml
- name: Deploy with Helm
  run: |
    helm upgrade --install task-manager ./helm/task-manager \
      --set taskService.image.tag=${{ steps.version.outputs.VERSION }} \
      --set userService.image.tag=${{ steps.version.outputs.VERSION }} \
      --set apiGateway.image.tag=${{ steps.version.outputs.VERSION }} \
      --wait
```
