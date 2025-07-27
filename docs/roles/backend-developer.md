# Backend Developer Guide

## Overview

As a Backend Developer, you focus on server-side logic, database interactions, API design, and system architecture. This role setup provides you with modern languages, database clients, API development tools, and testing frameworks to build robust and scalable backend services.

## Tools Installed

### Programming Languages
- **Python 3.13** - Modern Python with type hints and async support
- **Go** - High-performance systems programming
- **Rust** - Memory-safe systems programming
- **Java** - Enterprise applications (optional)
- **Node.js** - JavaScript runtime (optional)

### Language Tools
- **pyenv** - Python version management
- **pipx** - Install Python CLI tools in isolation
- **uv** - Fast Python package installer
- **poetry** - Python dependency management

### Database Clients
- **PostgreSQL 16** - PostgreSQL client tools
- **MySQL client** - MySQL/MariaDB tools
- **Redis** - In-memory data store client
- **SQLite** - Embedded database
- **pgcli** - Better PostgreSQL CLI
- **mycli** - Better MySQL CLI
- **mongosh** - MongoDB Shell (optional)

### API Development
- **httpie** - User-friendly HTTP client
- **grpcurl** - gRPC testing tool
- **protobuf** - Protocol buffers compiler
- **wrk** - HTTP benchmarking tool
- **vegeta** - Load testing tool

### Container Tools
- **docker-compose** - Multi-container applications
- **dive** - Docker image explorer

### GUI Applications
- **TablePlus** - Modern database GUI
- **Postman/Insomnia** - API development platform
- **OrbStack** - Lightweight Docker runtime

## Getting Started

### 1. Python Environment Setup
```bash
# Verify Python installation
python --version  # Should show 3.13.x

# Create a new project
mkdir my-api && cd my-api
python -m venv venv
source venv/bin/activate

# Install common packages
pip install fastapi uvicorn sqlalchemy alembic pytest black ruff

# Or use Poetry
poetry new my-api
cd my-api
poetry add fastapi uvicorn sqlalchemy
poetry install
```

### 2. Database Setup
```bash
# PostgreSQL
# Start PostgreSQL (if using Docker)
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:16

# Connect with pgcli
pgcli -h localhost -U postgres

# Redis
docker run -d \
  --name redis \
  -p 6379:6379 \
  redis:alpine

# Connect
redis-cli
```

### 3. Go Development
```bash
# Create a new Go module
mkdir my-service && cd my-service
go mod init github.com/username/my-service

# Install common packages
go get github.com/gin-gonic/gin
go get gorm.io/gorm
go get github.com/stretchr/testify
```

### 4. API Testing Setup
```bash
# Test with HTTPie
http GET localhost:8000/users
http POST localhost:8000/users name=John email=john@example.com

# Load testing
echo "GET http://localhost:8000/users" | vegeta attack -duration=30s | vegeta report
```

## Common Workflows

### Building REST APIs

#### Python (FastAPI)
```python
# main.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List

app = FastAPI()

class User(BaseModel):
    id: int
    name: str
    email: str

@app.get("/users", response_model=List[User])
async def get_users():
    return await fetch_users_from_db()

@app.post("/users", response_model=User)
async def create_user(user: User):
    return await save_user_to_db(user)

# Run with: uvicorn main:app --reload
```

#### Go (Gin)
```go
// main.go
package main

import (
    "github.com/gin-gonic/gin"
    "net/http"
)

type User struct {
    ID    int    `json:"id"`
    Name  string `json:"name"`
    Email string `json:"email"`
}

func main() {
    r := gin.Default()
    
    r.GET("/users", getUsers)
    r.POST("/users", createUser)
    
    r.Run(":8080")
}

// Run with: go run main.go
```

### Database Operations

#### SQL with SQLAlchemy
```python
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True)
    name = Column(String(100))
    email = Column(String(100), unique=True)

# Create tables
engine = create_engine("postgresql://user:pass@localhost/db")
Base.metadata.create_all(engine)

# Use session
Session = sessionmaker(bind=engine)
session = Session()
```

#### Redis Operations
```python
import redis

r = redis.Redis(host='localhost', port=6379, db=0)

# Set/Get
r.set('key', 'value')
value = r.get('key')

# Lists
r.lpush('queue', 'task1', 'task2')
task = r.rpop('queue')

# Pub/Sub
pubsub = r.pubsub()
pubsub.subscribe('channel')
```

### Testing

#### Python Testing
```python
# test_api.py
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_get_users():
    response = client.get("/users")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

# Run with: pytest
```

#### Go Testing
```go
// main_test.go
package main

import (
    "testing"
    "github.com/stretchr/testify/assert"
)

func TestGetUsers(t *testing.T) {
    users := getUsers()
    assert.NotEmpty(t, users)
}

// Run with: go test
```

### Performance Testing
```bash
# Basic load test
wrk -t12 -c400 -d30s http://localhost:8000/users

# Advanced with Vegeta
echo "GET http://localhost:8000/users" | \
  vegeta attack -rate=1000 -duration=30s | \
  vegeta encode | \
  vegeta report

# Custom scenarios
cat targets.txt | vegeta attack -rate=100 | vegeta report
```

## Best Practices

### 1. API Design
- **RESTful Principles**: Use proper HTTP methods and status codes
- **Versioning**: Always version your APIs (/api/v1/)
- **Documentation**: Use OpenAPI/Swagger specifications
- **Pagination**: Implement pagination for list endpoints
- **Rate Limiting**: Protect your APIs from abuse

### 2. Database Best Practices
- **Connection Pooling**: Always use connection pools
- **Migrations**: Use migration tools (Alembic, golang-migrate)
- **Indexes**: Create appropriate indexes for queries
- **N+1 Prevention**: Use eager loading when needed
- **Transactions**: Use transactions for data consistency

### 3. Security
- **Authentication**: Implement JWT or OAuth2
- **Input Validation**: Always validate and sanitize input
- **SQL Injection**: Use parameterized queries
- **Secrets Management**: Never hardcode secrets
- **HTTPS Only**: Always use TLS in production

### 4. Testing Strategy
- **Unit Tests**: Test individual functions
- **Integration Tests**: Test API endpoints
- **Load Tests**: Verify performance under load
- **Coverage**: Aim for >80% code coverage
- **CI/CD**: Automate testing in pipelines

### 5. Code Quality
- **Linting**: Use language-specific linters
- **Formatting**: Consistent code formatting
- **Type Hints**: Use static typing where available
- **Documentation**: Document complex logic
- **Code Reviews**: Always review before merging

## Learning Resources

### Books
- "Designing Data-Intensive Applications" by Martin Kleppmann
- "Clean Architecture" by Robert C. Martin
- "Building Microservices" by Sam Newman
- "Database Internals" by Alex Petrov

### Online Courses
- [Backend Master Class (Go)](https://www.youtube.com/playlist?list=PLy_6D98if3ULEtXtNSY_2qN21VCKgoQAE)
- [FastAPI Tutorial](https://fastapi.tiangolo.com/tutorial/)
- [System Design Interview](https://www.educative.io/courses/grokking-the-system-design-interview)

### Documentation
- [Python AsyncIO](https://docs.python.org/3/library/asyncio.html)
- [Go Documentation](https://go.dev/doc/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/documentation)

### Communities
- [Backend Development Subreddit](https://reddit.com/r/backend)
- [Python Discord](https://pythondiscord.com/)
- [Gophers Slack](https://gophers.slack.com/)
- [Database Administrators Stack Exchange](https://dba.stackexchange.com/)

## Troubleshooting

### Database Connection Issues
```bash
# Check PostgreSQL is running
pg_isready -h localhost -p 5432

# Check Redis
redis-cli ping

# Test connection
psql -h localhost -U postgres -d mydb
```

### Python Environment Issues
```bash
# Virtual environment not activated
source venv/bin/activate  # or venv\Scripts\activate on Windows

# Package conflicts
pip install --upgrade pip
pip install --force-reinstall package-name

# Poetry issues
poetry env info
poetry install --remove-untracked
```

### Performance Issues
```bash
# Profile Python code
python -m cProfile -s cumulative my_script.py

# Go profiling
go test -cpuprofile=cpu.prof -bench=.
go tool pprof cpu.prof
```

### API Debugging
```bash
# Verbose HTTP requests
http --verbose GET localhost:8000/users

# Check response time
time curl http://localhost:8000/users

# Debug headers
curl -I http://localhost:8000/users
```

## Next Steps

1. **Build a complete REST API** with authentication and database
2. **Implement caching** with Redis for better performance
3. **Set up message queuing** with RabbitMQ or Kafka
4. **Learn GraphQL** as an alternative to REST
5. **Explore microservices** architecture patterns
6. **Master database optimization** techniques

Remember: Great backend development is about building reliable, scalable, and maintainable systems. Focus on clean code, proper testing, and understanding the full stack!