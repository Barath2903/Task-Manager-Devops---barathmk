#!/bin/bash

# Verification script for Task Manager setup
# Run this to check if all prerequisites are installed

echo "=========================================="
echo "Task Manager - Setup Verification"
echo "=========================================="
echo ""

# Check Java
echo "Checking Java..."
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    echo "✓ Java found: $JAVA_VERSION"
    
    # Check if Java 17+
    JAVA_MAJOR=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
    if [ "$JAVA_MAJOR" -ge 17 ]; then
        echo "✓ Java version is 17 or higher"
    else
        echo "✗ Java version is less than 17. Please install JDK 17"
    fi
else
    echo "✗ Java not found. Please install JDK 17"
fi
echo ""

# Check Maven
echo "Checking Maven..."
if command -v mvn &> /dev/null; then
    MVN_VERSION=$(mvn -version | head -n 1)
    echo "✓ Maven found: $MVN_VERSION"
else
    echo "✗ Maven not found. Please install Maven 3.8+"
fi
echo ""

# Check Docker
echo "Checking Docker..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo "✓ Docker found: $DOCKER_VERSION"
    
    # Check if Docker daemon is running
    if docker ps &> /dev/null; then
        echo "✓ Docker daemon is running"
    else
        echo "✗ Docker daemon is not running. Please start Docker Desktop"
    fi
else
    echo "✗ Docker not found. Please install Docker"
fi
echo ""

# Check Docker Compose
echo "Checking Docker Compose..."
if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version)
    echo "✓ Docker Compose found: $COMPOSE_VERSION"
else
    echo "✗ Docker Compose not found. Please install Docker Compose"
fi
echo ""

# Check Git
echo "Checking Git..."
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo "✓ Git found: $GIT_VERSION"
else
    echo "✗ Git not found. Please install Git"
fi
echo ""

# Check project files
echo "Checking project files..."
if [ -f "pom.xml" ]; then
    echo "✓ Parent pom.xml found"
else
    echo "✗ pom.xml not found. Are you in the project root?"
fi

if [ -f "docker-compose.yml" ]; then
    echo "✓ docker-compose.yml found"
else
    echo "✗ docker-compose.yml not found"
fi

if [ -d "task-service" ] && [ -d "user-service" ] && [ -d "api-gateway" ]; then
    echo "✓ All microservices directories found"
else
    echo "✗ Some microservice directories are missing"
fi
echo ""

echo "=========================================="
echo "Verification Complete!"
echo "=========================================="
echo ""
echo "If all checks passed, you can run:"
echo "  docker-compose up -d"
echo ""
echo "For detailed instructions, see: STEP_BY_STEP_GUIDE.md"
