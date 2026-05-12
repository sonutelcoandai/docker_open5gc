#!/bin/bash

echo "Starting Open5GS Docker ...scenario ---sa-vonr-deploy.yaml"

echo "stoping already running open5gc docker instances...will take few sec.."

# Stop any existing containers
docker compose -f sa-vonr-deploy.yaml down

# Start fresh
echo "Starting fresh open5gc docker instances ....it will take few sec.."

docker compose -f sa-vonr-deploy.yaml up -d


# Show status
docker ps

echo "all services are up then Open5gc started successfully!"

