#
# PX4 ROS development environment
#

FROM px4io/px4-dev-simulation-focal:latest
LABEL maintainer="Nuno Marques <n.marques21@hotmail.com>"

ENV ROS_DISTRO noetic
ARG HOME=/root

# setup ros keys
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list' \
	&& sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list' \
	&& sh -c 'echo "deb http://packages.ros.org/ros-shadow-fixed/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-shadow.list' \
	&& apt-get update \
	&& apt-get -y --quiet --no-install-recommends install \
		geographiclib-tools \
		libeigen3-dev \
		libgeographic-dev \
		libopencv-dev \
		libyaml-cpp-dev \
		python3-rosdep \
		python3-catkin-tools \
		python3-catkin-lint \
		ros-$ROS_DISTRO-gazebo-ros-pkgs \
		ros-$ROS_DISTRO-mavlink \
		ros-$ROS_DISTRO-mavros \
		ros-$ROS_DISTRO-mavros-extras \
		ros-$ROS_DISTRO-octomap \
		ros-$ROS_DISTRO-octomap-msgs \
		ros-$ROS_DISTRO-pcl-conversions \
		ros-$ROS_DISTRO-pcl-msgs \
		ros-$ROS_DISTRO-pcl-ros \
		ros-$ROS_DISTRO-ros-base \
		ros-$ROS_DISTRO-rostest \
		ros-$ROS_DISTRO-rosunit \
		xvfb \
	&& geographiclib-get-geoids egm96-5 \
	&& apt-get -y autoremove \
	&& apt-get clean autoclean \
	&& rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# Clone the px4tools repository and install Python packages
RUN git clone https://github.com/dronecrew/px4tools.git /tmp/px4tools && \
    pip3 install -U \
		jupyter \
    	/tmp/px4tools \
    	pymavlink \
    	osrf-pycommon && \
    rm -rf /tmp/px4tools

# bootstrap rosdep
RUN rosdep init && rosdep update

# Create new workspace for aerial manipulator
RUN mkdir -p $HOME/lead/src

WORKDIR $HOME

#RUN git clone https://github.com/PX4/PX4-Autopilot.git

WORKDIR $HOME/lead/src
# simulation
RUN git clone https://github.com/ghost-drones/simulation.git

WORKDIR $HOME/lead/
RUN bash -c "source /opt/ros/noetic/setup.bash; source ~/.bashrc;  catkin build" 