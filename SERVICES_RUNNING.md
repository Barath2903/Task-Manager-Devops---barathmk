
## Current Status

All microservices are up and running:

- ✅ **API Gateway** - http://localhost:8080
- ✅ **Task Service** - http://localhost:8081  
- ✅ **User Service** - http://localhost:8082
- ✅ **PostgreSQL (Task DB)** - localhost:5434
- ✅ **PostgreSQL (User DB)** - localhost:5433

## Quick Test Commands

```bash
# Health check
curl http://localhost:8080/actuator/health

# Create a user
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"username":"john","email":"john@example.com","name":"John Doe"}'

# Create a task
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Complete project","description":"Finish the task manager","userId":1,"status":"PENDING"}'

# Get all tasks
curl http://localhost:8080/api/tasks

# Get all users
curl http://localhost:8080/api/users
```

## Service Management

```bash
# View all services
docker-compose ps

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Restart services
docker-compose restart

# Rebuild and restart
docker-compose up -d --build
```


## Next Steps

- Test all API endpoints
- Check service logs if needed
- Explore the API with Postman or curl
- Review the documentation files

