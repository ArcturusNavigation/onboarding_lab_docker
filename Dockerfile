# Start from ubuntu
FROM ubuntu:jammy


# Update so we can download packages
RUN apt-get update && apt-get upgrade -y


# Set the ROS distro
ENV ROS_DISTRO humble
ARG DEBIAN_FRONTEND=noninteractive


# Add the ROS deb repo to the apt sources list
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
		curl \
		wget \
		gnupg2 \
		lsb-release \
		ca-certificates \
        console-setup \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null


# Set up ROS
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-setuptools 

 
# Install ros2 packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
		ros-${ROS_DISTRO}-desktop \
		python3-colcon-common-extensions \
        ros-dev-tools \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean


# Set up ROS2
RUN rosdep init
RUN rosdep update --include-eol-distros


# Install VNC and things to install noVNC
RUN apt-get update && apt-get install -y \
    tigervnc-standalone-server \
    wget \
    git \
    python3-xdg \
    unzip


# Download NoVNC and unpack
ENV NO_VNC_VERSION 1.4.0
RUN wget -q https://github.com/novnc/noVNC/archive/v$NO_VNC_VERSION.zip
RUN unzip v$NO_VNC_VERSION.zip
RUN rm v$NO_VNC_VERSION.zip
RUN git clone https://github.com/novnc/websockify /noVNC-$NO_VNC_VERSION/utils/websockify


# Install a window manager
RUN apt-get update && apt-get install -y \
    openbox \
    x11-xserver-utils \
    xterm \
    dbus-x11


# Set up locales
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    locales \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
RUN locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV PYTHONIOENCODING=utf-8


# Install additional required packages for ROS
RUN apt update && apt install -y \
    ros-$ROS_DISTRO-tf2-geometry-msgs \
    ros-$ROS_DISTRO-tf2-sensor-msgs \
    ros-$ROS_DISTRO-tf-transformations \
    ros-$ROS_DISTRO-diagnostic-updater \
    ros-$ROS_DISTRO-geographic-msgs \
    ros-$ROS_DISTRO-mavros-msgs \
    ros-$ROS_DISTRO-pcl-ros \
    libgeographic-dev \
    libyaml-cpp-dev \
    build-essential


# Install some cool programs
RUN apt update && apt install -y \
    sudo \
    vim \
    neovim \
    emacs \
    nano \
    gedit \
    tmux \
    iputils-ping \
    protobuf-compiler \
    libb64-dev \
    htop \
    feh


# Install additional ros things
RUN apt update && pip install transforms3d \
    pip install imutils \
    pip install opencv-contrib-python


# Install Gazebo Garden
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
RUN apt update && apt install -y \
    gz-garden \
    python3-sdformat13 \
    ros-humble-ros-gzgarden \
    ros-humble-xacro


# Kill the bell!
RUN echo "set bell-style none" >> /etc/inputrc


# Copy in the entrypoint
COPY ./entrypoint.sh /usr/bin/entrypoint.sh
COPY ./xstartup.sh /usr/bin/xstartup.sh


# Copy in default config files
COPY ./config/bash.bashrc /etc/
COPY ./config/vimrc /etc/vim/vimrc
ADD ./config/openbox /etc/X11/openbox/
COPY ./config/XTerm /etc/X11/app-defaults/


# Create a user
RUN useradd -ms /bin/bash arcturus
RUN echo 'arcturus:arcturus' | chpasswd
RUN usermod -aG sudo arcturus
USER arcturus
WORKDIR /home/arcturus
