sudo docker run -it --rm \
  --runtime nvidia \
  --network host \
  -e ROS_DOMAIN_ID=7 \
  -e RMW_IMPLEMENTATION=rmw_cyclonedds_cpp \
  -e VEH_NAME=$VEH_NAME \
  -v $(pwd)/Volume:/Volume \
  foxy
