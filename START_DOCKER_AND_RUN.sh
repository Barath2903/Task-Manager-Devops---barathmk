#!/bin/bash

# Script to start Docker and then run the project

echo "=========================================="
echo "Task Manager - Docker Startup Script"
echo "=========================================="
echo ""

# Check if Docker is running
if docker ps &> /dev/null; then
    echo "✓ Docker is already running!"
else
    echo "Docker is not running. Attempting to start Docker Desktop..."
    
    # Try to start Docker Desktop on macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open -a Docker
        echo "Docker Desktop is starting..."
        echo "Please wait 10-30 seconds for Docker to fully start."
        echo ""
        
        # Wait for Docker to start
        echo "Waiting for Docker daemon to start..."
        MAX_WAIT=60
        WAIT_TIME=0
        
        while [ $WAIT_TIME -lt $MAX_WAIT ]; do
            if docker ps &> /dev/null; then
                echo "✓ Docker is now running!"
                break
            fi
            sleep 2
            WAIT_TIME=$((WAIT_TIME + 2))
            echo -n "."
        done
        
        if [ $WAIT_TIME -ge $MAX_WAIT ]; then
            echo ""
            echo "✗ Docker did not start within $MAX_WAIT seconds."
            echo "Please start Docker Desktop manually and run this script again."
            exit 1
        fi
    else
        echo "Please start Docker manually for your operating system."
        echo "On Linux: sudo systemctl start docker"
        exit 1
    fi
fi

echo ""
echo "=========================================="
echo "Starting Task Manager Services"
echo "=========================================="
echo ""

# Navigate to project directory
cd "$(dirname "$0")"

# Start services
echo "Starting all services with docker-compose..."
docker-compose up -d

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✓ Services are starting!"
    echo "=========================================="
    echo ""
    echo "Wait 30-60 seconds for all services to be ready."
    echo ""
    echo "Check status with:"
    echo "  docker-compose ps"
    echo ""
    echo "View logs with:"
    echo "  docker-compose logs -f"
    echo ""
    echo "Test the API:"
    echo "  curl http://localhost:8080/actuator/health"
    echo ""
else
    echo ""
    echo "✗ Failed to start services. Check the error messages above."
    exit 1
fi
