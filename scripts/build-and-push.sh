#!/bin/bash

# Docker Hub configuration - Update these values for your setup
DOCKER_USERNAME="yourusername"  # Change this to your Docker Hub username
IMAGE_NAME="mypython-app"
TAG="latest"

echo "=== Building and Pushing Python API Docker Image ==="

# Build the Docker image
echo "Building Docker image..."
docker build -f applications/Dockerfile.python -t ${IMAGE_NAME}:${TAG} .

# Tag for Docker Hub
echo "Tagging image for Docker Hub..."
docker tag ${IMAGE_NAME}:${TAG} ${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}

# Login to Docker Hub (you'll be prompted for credentials)
echo "Logging in to Docker Hub..."
docker login

# Push to Docker Hub
echo "Pushing image to Docker Hub..."
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}

echo "=== Build and Push Complete ==="
echo "Image available at: ${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}"
echo ""
echo "To use in Kubernetes:"
echo "  image: ${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}"