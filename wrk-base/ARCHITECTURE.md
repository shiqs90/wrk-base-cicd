# Architecture Overview

## System Design

```
User → app-node (HTTP) → wrk-ork (RPC) → wrk-book (RPC) → Storage
```
![App architecture](./architecture.png)

## Services

### app-node (API Gateway)
- **Port**: 3000
- **Purpose**: HTTP API endpoint for clients
- **Tech**: Node.js Express-like server
- **Handles**: Authentication, request routing, HTTP-to-RPC conversion

### wrk-ork (Orchestrator) 
- **Purpose**: Service discovery and load balancing
- **Manages**: Registration of wrk-book instances
- **Routes**: Requests to available book services

### wrk-book (Book Service)
- **Purpose**: Book management (CRUD operations)
- **Storage**: Hyperbee (distributed database)
- **Scalable**: Multiple instances can run

## Communication

- **External**: HTTP REST API (port 3000)
- **Internal**: RPC over Hyperswarm network
- **No Load Balancer**: Direct connection to app-node

## Data Flow

1. Client sends HTTP request to app-node
2. app-node forwards via RPC to wrk-ork
3. wrk-ork routes to appropriate wrk-book instance
4. wrk-book processes request and updates storage
5. Response flows back through the chain

## Monitoring

- **Prometheus**: Metrics collection (port 9090)
- **Grafana**: Dashboards and alerts (port 3001)
- **Health Checks**: Built into each service

## Deployment

- **Containerized**: Docker containers for each service
- **Orchestration**: Docker Compose
- **Scaling**: Horizontal scaling of wrk-book services
- **Storage**: Persistent volumes for data

## Key Features

- **Distributed**: Services can run on different machines
- **Fault Tolerant**: Service discovery handles failures
- **Scalable**: Add more book services as needed
- **Monitored**: Full observability stack included