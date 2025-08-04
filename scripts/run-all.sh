#!/bin/bash

set -e

# Clean up
docker stop helm-frontend helm-backend 2>/dev/null || true
docker rm helm-frontend helm-backend 2>/dev/null || true
docker network rm helm-net 2>/dev/null || true

# Rebuild frontend image
docker build -t helm-frontend:latest ./frontend

# Create network
docker network create helm-net

# Start backend
docker run -d --name helm-backend --network helm-net -p 8080:8080 helm-backend:v100

# Start frontend
docker run -d --name helm-frontend --network helm-net -p 80:80 helm-frontend:latest