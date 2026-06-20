#!/bin/bash
set -e

cd /Volume/gridnet_ws

source /opt/ros/foxy/setup.bash
colcon build 
source install/setup.bash

# Default namespace if not provided
: "${VEH_NAME:=PX00}"

exec ros2 launch gridnet_pkg gridnet.launch.py namespace:=$VEH_NAME
