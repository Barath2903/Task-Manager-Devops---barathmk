# Fix Docker Build Issue on Apple Silicon (ARM64)

## Problem
```
failed to resolve source metadata for docker.io/library/eclipse-temurin:17-jre-alpine: 
no match for platform in manifest: not found
```

## Solution Applied

I've updated all Dockerfiles to use `eclipse-temurin:17-jdk` and `eclipse-temurin:17-jre` instead of the Alpine versions. The regular Debian-based images have better multi-platform support for ARM64 (Apple Silicon).

## What Changed

- ✅ Changed from `eclipse-temurin:17-jdk-alpine` → `eclipse-temurin:17-jdk`
- ✅ Changed from `eclipse-temurin:17-jre-alpine` → `eclipse-temurin:17-jre`

## Now Try Building Again

```bash
cd "/Users/barath/Task Manager Devops"

# Clean any previous failed builds
docker-compose down
docker system prune -f

# Build and start
docker-compose up -d --build
```

## Alternative: If Still Having Issues

If you still encounter platform issues, you can explicitly set the platform in docker-compose.yml:

```yaml
task-service:
  build:
    context: .
    dockerfile: task-service/Dockerfile
    platforms:
      - linux/arm64
```

Or use Docker buildx for multi-platform builds:

```bash
docker buildx create --use
docker buildx build --platform linux/arm64 -t task-service:latest -f task-service/Dockerfile .
```

## Verify Docker Platform Support

```bash
# Check your Docker platform
docker version

# Check if images support ARM64
docker manifest inspect eclipse-temurin:17-jre | grep architecture
```

## Notes

- The regular (non-Alpine) images are slightly larger but have better compatibility
- Alpine images sometimes have limited platform support
- The Debian-based images work reliably on both Intel and Apple Silicon Macs
