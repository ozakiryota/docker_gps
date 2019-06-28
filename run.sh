#!/bin/bash

path_name=$(pwd)
image_name=${path_name##*/}

xhost +
nvidia-docker run -it --rm \
	--privileged \
	--env="DISPLAY" \
	--env="QT_X11_NO_MITSHM=1" \
	--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	--net=host \
	--device=/dev/ttyUSB0 \
	$image_name:latest 
	/bin/bash /home/small_gps_run.sh
