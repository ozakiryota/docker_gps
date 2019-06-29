# FROM ros:kinetic
FROM osrf/ros:kinetic-desktop

########## basis ##########
RUN apt-get update && apt-get install -y \
	vim \
	wget \
	unzip \
	git
########## ROS setup ##########
RUN mkdir -p /home/ros_catkin_ws/src && \
	cd /home/ros_catkin_ws/src && \
	/bin/bash -c "source /opt/ros/kinetic/setup.bash; catkin_init_workspace" && \
	cd /home/ros_catkin_ws && \
	/bin/bash -c "source /opt/ros/kinetic/setup.bash; catkin_make" && \
	echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc && \
	echo "source /home/ros_catkin_ws/devel/setup.bash" >> ~/.bashrc && \
	echo "export ROS_PACKAGE_PATH=\${ROS_PACKAGE_PATH}:/home/ros_catkin_ws" >> ~/.bashrc && \
	echo "export ROS_WORKSPACE=/home/ros_catkin_ws" >> ~/.bashrc && \
	echo "function cmk(){\n	lastpwd=\$OLDPWD \n	cpath=\$(pwd) \n	cd /home/ros_catkin_ws \n	catkin_make \$@ \n	cd \$cpath \n	OLDPWD=\$lastpwd \n}" >> ~/.bashrc
########## gps ##########
RUN apt-get update && apt-get install -y \
		ros-kinetic-nmea-msgs \
		ros-kinetic-nmea-navsat-driver \
		ros-kinetic-gps-umd
# RUN echo "#!/bin/bash\nsudo chmod a+rw /dev/ttyUSB0 &&\nroscore &\nrosrun nmea_navsat_driver nmea_topic_serial_reader _port:=\"/dev/ttyUSB0\" _baud:=\"36800\" &\nrosrun nmea_navsat_driver nmea_topic_driver &\nrosrun gps_common utm_odometry_node" >> /home/small_gps_run.sh && \
# 	chmod +x /home/small_gps_run.sh && \
# 	echo "#!/bin/bash\nsudo chmod a+rw /dev/ttyUSB0 &&\nroscore &\nrosrun nmea_navsat_driver nmea_topic_serial_reader _port:=\"/dev/ttyUSB0\" _baud:=\"19200\" &\nrosrun nmea_navsat_driver nmea_topic_driver _useRMC:=\"True\" &\nrosrun gps_common utm_odometry_node" >> /home/big_gps_run.sh && \
# 	chmod +x /home/big_gps_run.sh && \
# 	echo "#!/bin/bash\nrosbag record /fix /gps_odom /gps_vel /nmea_sentence /time_reference" >> /home/gps_record.sh && \
# 	chmod +x /home/gps_record.sh
RUN cd /home/ros_catkin_ws/src && \
	catkin_create_pkg gps_runner std_msgs rospy roscpp && \
	cd gps_runner && \
	mkdir launch && \
	cd /home/ros_catkin_ws && \
	/bin/bash -c "source /opt/ros/kinetic/setup.bash; catkin_make"
ADD small_gps_run.launch /home/ros_catkin_ws/src/gps_runner/launch/small_gps_run.launch
ADD big_gps_run.launch /home/ros_catkin_ws/src/gps_runner/launch/big_gps_run.launch
RUN echo "#!/bin/bash\nsource /opt/ros/kinetic/setup.bash\nsource /home/ros_catkin_ws/devel/setup.bash\nroslaunch gps_runner small_gps_run.launch" >> /home/small_gps_run.sh && \
	chmod +x /home/small_gps_run.sh
########## nvidia-docker1 hooks ##########
LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV PATH /usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}
######### initial position ##########
WORKDIR /home/ros_catkin_ws/src/gps_runner
CMD ["/home/small_gps_run.sh"]
