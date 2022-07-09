#!/usr/bin/env bash

BUILD_ARGS=''
[ "$1" == "push" ] && BUILD_ARGS="--platform linux/amd64,linux/arm64 --push" || BUILD_ARGS="--load"

IMAGE_NAME=gitfs
IMAGE_VERSION=0.0.0
IMAGE_FULL=ghcr.io/gobletqa/$IMAGE_NAME:$IMAGE_VERSION

echo "[Goblet] Building image $IMAGE_FULL"

IGNORE=$(docker buildx create --name goblet)
docker buildx use goblet
docker buildx build $BUILD_ARGS -t $IMAGE_FULL .

