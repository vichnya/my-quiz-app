#!/bin/bash

echo "Stop container"
docker stop glav
docker rm glav
docker image rm vishnya1chern/my-nginx #${{ secrets.DOCKER_USERNAME }}/${{ secrets.DOCKER_REPO_NAME }}
echo "Pull image"
docker pull vishnya1chern/my-nginx #${{ secrets.DOCKER_USERNAME }}/${{ secrets.DOCKER_REPO_NAME }}
echo "Start frontend container"
docker run -p 80:80 --name glav -d vishnya1chern/my-nginx #${{ secrets.DOCKER_USERNAME }}/${{ secrets.DOCKER_REPO_NAME }}
echo "Finish deploying!"
