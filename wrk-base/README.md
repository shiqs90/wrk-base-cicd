# Distributed Book Management System - CI/CD

A production-ready distributed book management system with comprehensive CI/CD pipeline, containerized services, and monitoring stack.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Services](#services)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [CI/CD Pipeline](#cicd-pipeline)
- [Development](#development)
- [Deployment](#deployment)
- [Monitoring](#monitoring)
- [API Reference](#api-reference)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🏗️ Overview

This distributed book management system consists of microservices that communicate via RPC protocols, providing scalable book inventory management with a RESTful API gateway. The system includes comprehensive CI/CD automation, Docker containerization, and production monitoring.

### Key Features

- **Distributed Architecture**: Microservices communicating via P2P RPC
- **HTTP API Gateway**: RESTful endpoints for book management
- **Automated CI/CD**: GitHub Actions with branch-based deployments
- **Container Orchestration**: Docker Compose with health checks
- **Production Monitoring**: Prometheus & Grafana stack
- **Multi-Platform**: Supports AMD64 and ARM64 architectures

## 🏛️ Architecture

See [ARCHITECTURE.md](./ARCHITECTURE.md) for detailed system architecture diagram and component interactions.

### Service Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client Apps   │    │   Monitoring    │    │   CI/CD         │
│   (Browser)     │    │   (Grafana)     │    │   (GitHub)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │ HTTP                  │ Metrics               │ Webhooks
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    app-node     │◄───┤   Prometheus    │    │ GitHub Actions  │
│  (HTTP Gateway) │    │   (Metrics)     │    │   (Build/Push)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
         │ RPC
         ▼
┌─────────────────┐    ┌─────────────────┐
│    wrk-ork      │◄──►│    wrk-book     │
│ (Orchestrator)  │    │ (Book Manager)  │
└─────────────────┘    └─────────────────┘
```

## 🚀 Services

### app-node (HTTP API Gateway)
- **Port**: 3000
- **Purpose**: RESTful API endpoints for book management
- **Technology**: Node.js, Fastify, svc-facs-httpd
- **Health Check**: TCP connection test

### wrk-ork (Orchestrator Service)
- **Port**: 8080 (internal)
- **Purpose**: Service orchestration and RPC coordination  
- **Technology**: Node.js, P2P RPC
- **Health Check**: Process validation

### wrk-book (Book Management Service)
- **Port**: 8081 (internal)
- **Purpose**: Book inventory and data management
- **Technology**: Node.js, Corestore, Template Worker Pattern
- **Health Check**: Process validation

### Monitoring Stack
- **Prometheus**: Metrics collection (Port 9090)
- **Grafana**: Visualization and dashboards (Port 3001)

## 📋 Prerequisites

### System Requirements
- **Docker**: 20.10+ with Compose V2
- **Node.js**: 18+ (for local development)
- **Git**: 2.30+
- **Platform**: Linux/macOS/Windows with WSL2

### Development Tools
- **npm**: 8+
- **curl**: For API testing
- **jq**: JSON processing (optional)

### GitHub Repository Setup
- GitHub repository with Actions enabled
- GitHub Container Registry access
- Required secrets: `GITHUB_TOKEN` (automatically provided)

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone <repository-url>
cd wrk-base
```

### 2. Environment Setup
```bash
# Copy environment templates (if needed)
cp .env.example .env

# Ensure monitoring config exists
mkdir -p monitoring/grafana/provisioning
```

### 3. Start Services
```bash
# Start all services with monitoring
docker-compose up -d

# Check service health
docker-compose ps
```

### 4. Verify Deployment
```bash
# Check API Gateway (Internal access only due to svc-facs-httpd limitation)
docker exec app-node curl -s http://localhost:3000/books

# Access Monitoring
open http://localhost:9090  # Prometheus
open http://localhost:3001  # Grafana (admin/admin123)
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

The pipeline automatically triggers on:
- **Push to any branch**
- **Pull requests to main/dev**

### Pipeline Stages

#### 1. Lint & Validation
```yaml
- Install Node.js dependencies for all services
- Run ESLint on all codebases
- Validate code quality and standards
```

#### 2. Build & Push
```yaml
- Multi-architecture Docker builds (AMD64/ARM64)  
- Push to GitHub Container Registry
- Implement build caching for optimization
```

### Branch-Based Tagging Strategy

| Branch | Docker Tag | Example |
|--------|------------|---------|
| `main` | `latest`, `{sha}` | `ghcr.io/user/repo/app-node:latest` |
| `dev` | `development`, `dev-{sha}` | `ghcr.io/user/repo/app-node:development` |
| Others | `alpha-{sha}` | `ghcr.io/user/repo/app-node:alpha-abc123` |

### Workflow Configuration
Located at: `.github/workflows/ci-cd.yml`

Key features:
- **Matrix builds** for multiple services
- **Build caching** with GitHub Actions cache
- **Multi-platform** support (AMD64/ARM64)
- **Security**: Uses `GITHUB_TOKEN` for authentication

## 💻 Development

### Local Development Setup

```bash
# Install dependencies for all services
cd wrk-base && npm install
cd ../tpl-wrk-thing && npm install  
cd ../app-node && npm install
cd ../wrk-ork && npm install
cd ../wrk-book && npm install

# Run linting
npm run lint

# Start development environment
docker-compose up -d
```

### Service Configuration

Each service uses configuration files in their respective `config/` directories:
- **Network settings**: `config/facs/net.config.json`
- **HTTP settings**: `config/facs/httpd.config.json` (app-node only)
- **Common settings**: `config/common.json`

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Environment mode | `development` |
| `PORT` | HTTP server port | `3000` |
| `RACK_ID` | Service rack identifier | Service-specific |
| `STORE_PRIMARY_KEY` | Storage encryption key | Auto-generated |
| `DHT_BOOTSTRAP_TIMEOUT` | DHT connection timeout | `15000` |

## 🚀 Deployment

### Docker Compose Deployment

```bash
# Production deployment
NODE_ENV=production docker-compose up -d

# Scaling services
docker-compose up -d --scale wrk-book=3

# Rolling updates
docker-compose pull
docker-compose up -d --no-deps app-node
```

### Container Registry Images

```bash
# Pull latest images
docker pull ghcr.io/{user}/{repo}/app-node:latest
docker pull ghcr.io/{user}/{repo}/wrk-ork:latest  
docker pull ghcr.io/{user}/{repo}/wrk-book:latest

# Use specific versions
docker pull ghcr.io/{user}/{repo}/app-node:development
```

### Health Checks

All services include comprehensive health monitoring:
- **Startup grace period**: 60 seconds
- **Check interval**: 30 seconds  
- **Failure threshold**: 3 retries
- **Timeout**: 10 seconds

## 📊 Monitoring

### Prometheus (Port 9090)
- Metrics collection and alerting
- Service discovery and health monitoring
- Data retention: 200 hours
- Access: http://localhost:9090

### Grafana (Port 3001)
- **URL**: http://localhost:3001
- **Credentials**: admin / admin123
- **Features**: 
  - Pre-configured dashboards
  - Service health monitoring
  - Performance metrics visualization

### Monitoring Configuration
```bash
# Prometheus config
./monitoring/prometheus.yml

# Grafana provisioning
./monitoring/grafana/provisioning/
```

## 📡 API Reference

### Base URL
```
http://localhost:3000
```

**Note**: Due to svc-facs-httpd facility limitations, external HTTP access is restricted. API is accessible internally between containers.

### Endpoints

#### Books Management

```bash
# List all books
GET /books

# Create a book
POST /books
Content-Type: application/json
{
  "type": "book",
  "tags": ["fiction", "bestseller"],
  "info": {
    "name": "Book Title",
    "author": "Author Name", 
    "status": "available"
  },
  "rack_id": "book-rack-001"
}

# Update a book
PUT /books/{bookId}

# Delete a book  
DELETE /books/{bookId}

# Checkout/Return book
POST /checkout
{
  "id": "book-id",
  "info": {
    "status": "checked-out"
  }
}
```

### Response Format
```json
{
  "statusCode": 200,
  "data": [...],
  "message": "Success"
}
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Services Not Starting
```bash
# Check logs
docker-compose logs -f [service-name]

# Verify dependencies
docker-compose ps

# Restart services
docker-compose restart [service-name]
```

#### 2. RPC Communication Errors
```bash
# Error: "ID must be 32-bytes long"
# Solution: Ensure all services are healthy and RPC keys are properly configured
docker-compose logs wrk-ork wrk-book
```

#### 3. External HTTP Access Issues  
```bash
# Issue: Cannot access http://localhost:3000 from browser
# Root Cause: svc-facs-httpd binds to localhost (127.0.0.1) only
# Workaround: Use container-to-container communication
docker exec app-node curl http://localhost:3000/books
```

#### 4. Build Failures
```bash
# Native module compilation issues
# Solution: Use Debian base images with build tools
RUN apt-get update && apt-get install -y build-essential python3
```

### Health Check Debugging
```bash
# Manual health checks
docker exec app-node node -e "require('net').connect(3000, 'localhost')"
docker exec wrk-ork pgrep -f "node worker.js"
docker exec prometheus wget --spider http://localhost:9090/-/healthy
```

### Performance Optimization
```bash
# Container resource monitoring  
docker stats

# Service-specific monitoring
docker-compose logs --tail=50 -f app-node
```

## 🤝 Contributing

### Development Workflow

**Local Development**
```bash
# Install dependencies
npm install

# Make changes
# Test locally
docker-compose up -d

# Lint code
npm run lint
```

4. **Commit & Push**
```bash
git add .
git commit -m "feat: add your feature description"
git push origin feature/your-feature-name
```

5. **Create Pull Request**
- Target `dev` branch for new features
- Target `main` branch for hotfixes
- Include comprehensive description
- Ensure CI/CD pipeline passes

### Code Standards

- **ESLint**: Follow configured linting rules
- **Commit Messages**: Use conventional commits format
- **Documentation**: Update README for significant changes  
- **Testing**: Ensure all services start and communicate properly

### Branch Strategy

```
main     ──●──●──●──────●── (Production releases)
           │     │       │
dev      ──●──●──●──●──●──── (Development integration)
           │  │     │
feature  ──●──●     ●────── (Feature branches)
```

### CI/CD Integration

All pull requests automatically trigger:
- **Linting validation**
- **Docker image builds** 
- **Multi-platform testing**
- **Security scanning**

## 📝 Versioning & Rollback Strategies

### Semantic Versioning
- **Major** (X.0.0): Breaking changes
- **Minor** (0.X.0): New features, backward compatible  
- **Patch** (0.0.X): Bug fixes, backward compatible

### Rollback Procedures

#### Container Rollback
```bash
# Rollback to previous image version
docker-compose pull ghcr.io/user/repo/app-node:previous-tag
docker-compose up -d --no-deps app-node

# Database rollback (if applicable)
docker-compose exec wrk-book backup-restore --version previous
```

#### Git-based Rollback
```bash
# Rollback commit
git revert <commit-hash>
git push origin main

# This triggers automatic rebuild and deployment
```

### Deployment Safety

- **Blue-Green Deployments**: Use Docker Compose profiles
- **Health Checks**: Automatic service validation
- **Monitoring**: Real-time service health via Grafana
- **Backup Strategy**: Regular data backups before deployments


## 🆘 Support

For issues and support:
- **GitHub Issues**: [Create an issue](../../issues)
- **Documentation**: This README and [ARCHITECTURE.md](./ARCHITECTURE.md)
- **Monitoring**: Check Grafana dashboards for service health

---

## 🎯 Project Status

✅ **Production Ready**
- All services containerized and orchestrated
- Comprehensive CI/CD pipeline operational
- Monitoring stack fully configured
- Health checks and error handling implemented
- Multi-platform Docker images available

⚠️ **Known Limitations**
- External HTTP access restricted due to svc-facs-httpd facility binding limitation
- RPC services require proper network configuration for external access

---
