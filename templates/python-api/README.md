# Python API Template

A modern Python REST API template using FastAPI, with async support, automatic documentation, and production-ready features.

## Features

- ⚡ FastAPI framework for high performance
- 📚 Automatic API documentation (Swagger/OpenAPI)
- 🔒 JWT authentication ready
- 🗄️ SQLAlchemy ORM with Alembic migrations
- 🧪 Pytest testing setup
- 🐳 Docker and docker-compose ready
- 📊 Structured logging
- ⚙️ Environment-based configuration
- 🎯 Type hints throughout
- 🔧 Pre-commit hooks

## Quick Start

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Copy environment variables
cp .env.example .env

# Run database migrations
alembic upgrade head

# Start the development server
uvicorn app.main:app --reload
```

## Project Structure

```
.
├── app/
│   ├── __init__.py
│   ├── main.py           # FastAPI application
│   ├── config.py         # Configuration management
│   ├── database.py       # Database connection
│   ├── models/           # SQLAlchemy models
│   ├── schemas/          # Pydantic schemas
│   ├── api/              # API endpoints
│   │   ├── v1/
│   │   │   ├── auth.py
│   │   │   ├── users.py
│   │   │   └── items.py
│   ├── core/             # Core functionality
│   │   ├── security.py
│   │   └── deps.py
│   └── utils/            # Utility functions
├── migrations/           # Alembic migrations
├── tests/               # Test files
├── docker/              # Docker configurations
├── .env.example         # Example environment variables
├── requirements.txt     # Production dependencies
├── requirements-dev.txt # Development dependencies
├── Dockerfile
├── docker-compose.yml
└── README.md
```

## API Documentation

Once running, visit:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Testing

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test file
pytest tests/test_users.py
```

## Docker

```bash
# Build and run with docker-compose
docker-compose up --build

# Run in production mode
docker-compose -f docker-compose.prod.yml up -d
```

## Database Migrations

```bash
# Create a new migration
alembic revision --autogenerate -m "Add user table"

# Apply migrations
alembic upgrade head

# Rollback one revision
alembic downgrade -1
```

## Environment Variables

See `.env.example` for all available options:
- `DATABASE_URL`: PostgreSQL connection string
- `SECRET_KEY`: JWT secret key
- `ENVIRONMENT`: dev/staging/production
- `LOG_LEVEL`: Logging level

## Deployment

### Heroku
```bash
heroku create your-api-name
heroku addons:create heroku-postgresql:hobby-dev
git push heroku main
```

### AWS ECS
See `docker/deploy/` for ECS task definitions

### Kubernetes
See `k8s/` for Kubernetes manifests