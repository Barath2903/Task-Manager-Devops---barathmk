# 🚀 START HERE - Quick Start Guide

## Fastest Way to Run (5 Minutes)

### 1. Verify Prerequisites (1 minute)

Run the verification script:
```bash
cd "/Users/barath/Task Manager Devops"
./verify-setup.sh
```

**Required:**
- ✅ Java 17
- ✅ Maven 3.8+
- ✅ Docker & Docker Compose

**If missing, install:**
- macOS: `brew install openjdk@17 maven docker`
- Linux: `sudo apt install openjdk-17-jdk maven docker.io docker-compose`

### 2. Start Everything (2 minutes)

```bash
# Navigate to project
cd "/Users/barath/Task Manager Devops"

# Start all services
docker-compose up -d

# Wait 30-60 seconds for services to start
# Check status
docker-compose ps
```

### 3. Test It Works (2 minutes)

```bash
# Test API Gateway
curl http://localhost:8080/actuator/health

# Create a user
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "name": "Test User"
  }'

# Create a task
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "My First Task",
    "description": "Testing the API",
    "userId": 1,
    "status": "PENDING"
  }'

# Get all tasks
curl http://localhost:8080/api/tasks
```

### 4. View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f task-service
```

### 5. Stop When Done

```bash
docker-compose down
```

---

## 📚 Detailed Guides

- **Full Step-by-Step:** See `STEP_BY_STEP_GUIDE.md`
- **Quick Reference:** See `QUICKSTART.md`
- **CI/CD Pipeline:** See `PIPELINE_OVERVIEW.md`
- **Project Overview:** See `README.md`

---

## 🎯 What's Running?

After `docker-compose up -d`, you have:

| Service | Port | URL |
|---------|------|-----|
| **API Gateway** | 8080 | http://localhost:8080 |
| Task Service | 8081 | http://localhost:8081 |
| User Service | 8082 | http://localhost:8082 |
| PostgreSQL (Task) | 5432 | localhost:5432 |
| PostgreSQL (User) | 5433 | localhost:5433 |

**All API requests go through the Gateway at port 8080**

---

## 🔧 Troubleshooting

### Port Already in Use?
```bash
# Find what's using the port
lsof -i :8080
# Kill it or change ports in docker-compose.yml
```

### Services Won't Start?
```bash
# Check logs
docker-compose logs

# Restart
docker-compose down
docker-compose up -d
```

### Can't Connect to Database?
```bash
# Check if databases are running
docker ps | grep postgres

# Check database logs
docker-compose logs postgres-task
```

---

## 📖 Next Steps

1. ✅ **Verify setup:** `./verify-setup.sh`
2. ✅ **Start services:** `docker-compose up -d`
3. ✅ **Test API:** Use curl commands above
4. 📖 **Read documentation:** Check other .md files
5. 🧪 **Run tests:** `mvn test`
6. 🚀 **Deploy to K8s:** See Kubernetes section in guides

---

## 💡 Tips

- **Use Postman/Insomnia** for easier API testing
- **Check logs** if something doesn't work: `docker-compose logs -f`
- **All services restart** when you change code (if using volume mounts)
- **Database data persists** in Docker volumes

---

**Need help?** Check `STEP_BY_STEP_GUIDE.md` for detailed instructions!
