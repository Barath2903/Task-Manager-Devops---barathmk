#!/bin/bash

# Script to rebuild and start all services

echo "=========================================="
echo "Rebuilding and Starting Task Manager"
echo "=========================================="
echo ""

cd "$(dirname "$0")"

# Stop any running containers
echo "Stopping existing containers..."
docker-compose down

# Remove old images to force rebuild
echo "Cleaning up old images..."
docker-compose rm -f

# Build and start
echo ""
echo "Building and starting services..."
echo "This may take 5-10 minutes on first run..."
echo ""

docker-compose up -d --build

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✓ Build completed!"
    echo "=========================================="
    echo ""
    echo "Waiting for services to start (30 seconds)..."
    sleep 30
    
    echo ""
    echo "Checking service status..."
    docker-compose ps
    
    echo ""
    echo "Testing API Gateway..."
    curl -s http://localhost:8080/actuator/health || echo "Service not ready yet, wait a bit longer"
    
    echo ""
    echo ""
    echo "View logs with: docker-compose logs -f"
    echo "Check status: docker-compose ps"
else
    echo ""
    echo "✗ Build failed. Check the error messages above."
    echo "View logs: docker-compose logs"
    exit 1
fi
