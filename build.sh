#!/bin/bash

# Переменные
DOCKER_IMAGE_NAME="my-nginx-app"
DOCKER_IMAGE_TAG="latest"

# Сборка Docker-образа
docker build -t "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}" .