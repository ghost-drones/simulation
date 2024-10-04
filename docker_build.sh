#!/bin/bash

echo "LEAD-Ubuntu-20.04 PX4 Docker Image"

echo "Building ROS Noetic with PX4 sim"

docker build \
    -f Dockerfile \
    -t ghost_px4 .