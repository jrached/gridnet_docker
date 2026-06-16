xhost +local:root
sudo docker run -it --rm \
  --gpus all \
  --network host \
  -e ROS_DOMAIN_ID=7 \
  -e RMW_IMPLEMENTATION=rmw_cyclonedds_cpp \
  -e VEH_NAME=$VEH_NAME \
  -v $(pwd)/Volume:/Volume \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  foxy
