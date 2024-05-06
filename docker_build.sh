#!/bin/bash

echo "LEAD-Ubuntu-20.04 Docker Image"

echo "Building ROS Noetic"

docker build \
    -f Dockerfile \
    -t lead_drone .