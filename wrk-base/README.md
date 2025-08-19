# Distributed Book Management System - CI/CD

This repository contains a distributed book management system with comprehensive CI/CD pipeline.

## Services
- **app-node**: HTTP API gateway service
- **wrk-ork**: Orchestrator service  
- **wrk-book**: Book management service

## Quick Start
```bash
docker-compose up -d
```

## CI/CD Pipeline
- Automated testing and building on every push
- Branch-based Docker image tagging
- Multi-architecture support (amd64/arm64)