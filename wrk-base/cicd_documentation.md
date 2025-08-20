# CI/CD Pipeline Documentation

## Overview

The CI/CD pipeline is implemented using GitHub Actions and consists of automated testing, building, and publishing of Docker images to GitHub Container Registry (GHCR).

## Workflow Structure

### File Location
`.github/workflows/ci-cd.yml`

### Workflow Triggers

#### Push Events
```yaml
on:
  push:
    branches: ["**"]  # Triggers on push to any branch
```

#### Pull Request Events
```yaml
on:
  pull_request:
    branches: [main, dev]  # Only for PRs to main or dev
```

## Jobs

### Job 1: Lint
**Purpose**: Code quality and syntax validation

**Triggers**:
- All pushes to any branch
- Pull requests to `main` and `dev` branches

**Steps**:
1. **Checkout**: `actions/checkout@v4`
2. **Node.js Setup**: Version 18 with npm caching
3. **Install Dependencies**: For all 5 services
   - wrk-base
   - tpl-wrk-thing  
   - app-node
   - wrk-ork
   - wrk-book
4. **Run Linting**: ESLint with Standard configuration

**Dependencies Installation**:
```bash
cd wrk-base/wrk-base && npm install
cd wrk-base/tpl-wrk-thing && npm install  
cd wrk-base/app-node && npm install
cd wrk-base/wrk-ork && npm install
cd wrk-base/wrk-book && npm install
```

### Job 2: Build and Push
**Purpose**: Build Docker images and publish to registry

**Triggers**:
- Successful completion of lint job
- Only on push events (not PRs)

**Strategy**: Matrix build for parallel processing
```yaml
strategy:
  matrix:
    service: [app-node, wrk-ork, wrk-book]
```

**Steps**:
1. **Checkout**: Source code checkout
2. **Docker Buildx**: Multi-architecture build setup
3. **Registry Login**: GitHub Container Registry authentication
4. **Tag Generation**: Branch-based image tagging
5. **Build & Push**: Multi-architecture Docker images

**Important Note**: The pipeline only builds and pushes images to GHCR. There is no automated deployment stage.

## Branching Strategy & Tagging

### Main Branch (`main`)
**Image Tags**:
- `latest`
- `<commit-sha>`

**Use Case**: Production releases

**Example**:
```
ghcr.io/username/repo/app-node:latest
ghcr.io/username/repo/app-node:abc1234
```

### Development Branch (`dev`)  
**Image Tags**:
- `development`
- `dev-<commit-sha>`

**Use Case**: Staging and integration testing

**Example**:
```
ghcr.io/username/repo/app-node:development
ghcr.io/username/repo/app-node:dev-abc1234
```

### Feature Branches (others)
**Image Tags**:
- `alpha-<commit-sha>`

**Use Case**: Feature development and testing

**Example**:
```
ghcr.io/username/repo/app-node:alpha-abc1234
```

## Tag Generation Logic

```bash
SERVICE="${{ matrix.service }}"
REPO_NAME=$(echo "${{ github.repository }}" | tr '[:upper:]' '[:lower:]')
BASE_NAME="${{ env.REGISTRY }}/${REPO_NAME}/${SERVICE}"

if [ "${{ github.ref }}" = "refs/heads/main" ]; then
  TAGS="${BASE_NAME}:latest,${BASE_NAME}:${{ github.sha }}"
elif [ "${{ github.ref }}" = "refs/heads/dev" ]; then
  TAGS="${BASE_NAME}:development,${BASE_NAME}:dev-${{ github.sha }}"
else
  TAGS="${BASE_NAME}:alpha-${{ github.sha }}"
fi
```

## Docker Build Configuration

### Multi-Architecture Support
```yaml
platforms: linux/amd64,linux/arm64
```

### Build Context
```yaml
context: ./wrk-base
file: ./wrk-base/Dockerfile.${{ matrix.service }}
```

### Caching Strategy
```yaml
cache-from: type=gha
cache-to: type=gha,mode=max
```

## Registry Configuration

### GitHub Container Registry (GHCR)
```yaml
env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}
```

### Authentication
```yaml
registry: ${{ env.REGISTRY }}
username: ${{ github.actor }}
password: ${{ secrets.GITHUB_TOKEN }}
```

## Security Features

### Permissions
```yaml
permissions:
  contents: read    # Read repository contents
  packages: write   # Write to GHCR
```

### Token Usage
- Uses `GITHUB_TOKEN` (automatically provided)
- No custom secrets required
- Scoped permissions for security

## Pipeline Flow

```
Push/PR → Lint Job → Build Matrix → Tag Images → Push to GHCR
```

### Parallel Execution
- 3 services build simultaneously
- Independent failure (one service failure doesn't stop others)
- Faster overall pipeline execution

### Build Optimization
- GitHub Actions cache for Docker layers
- Multi-stage Dockerfiles for smaller images
- npm cache for faster dependency installation

## Versioning & Rollback Strategy

### Semantic Versioning
The project follows semantic versioning for releases:
- **MAJOR**: Breaking changes to API or architecture
- **MINOR**: New features that are backward compatible
- **PATCH**: Bug fixes and minor improvements

### Git Tag Strategy
```bash
# Create release tags
git tag -a v1.2.3 -m "Release version 1.2.3"
git push origin v1.2.3

# Hotfix tags
git tag -a v1.2.4-hotfix.1 -m "Hotfix for critical issue"
```

### Rollback Procedures

#### Quick Rollback (Docker Compose)
```bash
# Rollback to previous version
docker-compose down
export IMAGE_TAG=v1.2.2  # Specify version
docker-compose up -d
```

#### Service-Specific Rollback
```bash
# Rollback single service
docker-compose stop app-node
docker run -d --name app-node-v1.2.2 \
  --network wrk-network \
  ghcr.io/your-org/app-node:v1.2.2
```

## Best Practices

### Code Quality
1. All code must pass ESLint Standard configuration
2. Update documentation for API changes
3. Follow security best practices

### Development Workflow
1. Create feature branches from `dev`
2. All changes must go through PR review
3. Test locally before pushing
4. Ensure all pipeline checks pass

### Docker Best Practices
1. Multi-stage builds to minimize image size
2. Non-root users for security
3. Health checks for all services
4. Proper secret management