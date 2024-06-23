FROM lmark1/uav_ros_simulation:focal-bin-0.0.1 as uav_base


ARG SSH_KEY
ENV SSH_KEY=$SSH_KEY

# Make ssh dir
RUN mkdir $HOME/.ssh/
 
# Copy over private key, and set permissions

RUN echo "$SSH_KEY" > $HOME/.ssh/id_rsa
RUN chmod 600 $HOME/.ssh/id_rsa
 
# Create known_hosts
RUN touch $HOME/.ssh/known_hosts

# Add bitbuckets key
RUN ssh-keyscan bitbucket.org >> $HOME/.ssh/known_hosts
RUN ssh-keyscan github.com >> $HOME/.ssh/known_hosts
RUN ssh-keyscan gitlab.com >> $HOME/.ssh/known_hosts

ARG CATKIN_WORKSPACE=uav_ws
ARG DEBIAN_FRONTEND=noninteractive
ARG HOME=/root
ARG ROS_DISTRO=noetic

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute

# Install apt packages
RUN apt-get install -y \
    nano 

RUN apt-get update

# Create new workspace for aerial manipulator
RUN mkdir -p $HOME/lead/src
WORKDIR $HOME/lead/src
# cbr_simulation
RUN git clone https://github.com/luccagandra/cbr_simulation.git
# ardupilot_models
RUN git clone https://github.com/larics/ardupilot_gazebo.git
# mav_comm
RUN git clone https://github.com/larics/mav_comm.git -b larics_master
# rotors simulator
RUN git clone https://github.com/larics/rotors_simulator.git -b larics_noetic_master
WORKDIR $HOME/lead/
RUN bash -c "source /opt/ros/noetic/setup.bash; source ~/.bashrc;  catkin build" 

# Add localhost for it 
RUN echo "export ROS_MASTER_URI=http://127.0.0.1:11311" >> ~/.bashrc
RUN echo "export ROS_HOSTNAME=127.0.0.1" >> ~/.bashrc
RUN echo "source /root/lead/devel/setup.bash" >> ~/.bashrc 

CMD ["bash"]