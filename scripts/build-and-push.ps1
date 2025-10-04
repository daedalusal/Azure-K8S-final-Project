# Docker Hub configuration - Update these values for your setup
$DOCKER_USERNAME = "yourusername"  # Change this to your Docker Hub username
$IMAGE_NAME = "mypython-app"
$TAG = "latest"

Write-Host "=== Building and Pushing Python API Docker Image ===" -ForegroundColor Green

# Build the Docker image
Write-Host "Building Docker image..." -ForegroundColor Yellow
docker build -f applications/Dockerfile.python -t "${IMAGE_NAME}:${TAG}" .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed!" -ForegroundColor Red
    exit 1
}

# Tag for Docker Hub
Write-Host "Tagging image for Docker Hub..." -ForegroundColor Yellow
docker tag "${IMAGE_NAME}:${TAG}" "${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}"

# Login to Docker Hub (you'll be prompted for credentials)
Write-Host "Logging in to Docker Hub..." -ForegroundColor Yellow
docker login

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker login failed!" -ForegroundColor Red
    exit 1
}

# Push to Docker Hub
Write-Host "Pushing image to Docker Hub..." -ForegroundColor Yellow
docker push "${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}"

if ($LASTEXITCODE -eq 0) {
    Write-Host "=== Build and Push Complete ===" -ForegroundColor Green
    Write-Host "Image available at: ${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To use in Kubernetes:" -ForegroundColor Cyan
    Write-Host "  image: ${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}" -ForegroundColor White
} else {
    Write-Host "Docker push failed!" -ForegroundColor Red
    exit 1
}