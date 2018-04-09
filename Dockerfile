FROM ubuntu:16.04
MAINTAINER Anatolii Volkodav <volkodavav@gmail.com>
ENV ROS_DISTRO=kinetic

ENV DEBIAN_FRONTEND=noninteractive

ENV USER=root
ENV HOME=/work
WORKDIR ${HOME}

RUN sed -i -- 's/^#deb/deb/g' /etc/apt/sources.list \
    && sed -i -- 's/^# deb/deb/g' /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y locales \
    && locale-gen en_US.UTF-8 \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

ENV TZ=Etc/UTC \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    SHELL=/bin/bash \
    SSH_PORT=2222 \
    VNC_PORT=5900 \
    DISPLAY=:0 \
    VNC_SCREEN_WHD=1280x1024x24

RUN echo $TZ >/etc/timezone \
    && apt-get update \
    && apt-get install -y tzdata \
    && rm /etc/localtime \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y \
        xfce4 \
        xfce4-terminal \
        xfce4-goodies \
        firefox \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y \
        x11vnc \
        xvfb \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y \
        supervisor \
        git \
        build-essential \
        less \
        sed \
        vim \
        mc \
        screen \
        curl \
        wget \
        sudo \
        net-tools \
        netbase \
        telnet \
        bzip2 \
        unzip \
        software-properties-common \
        ca-certificates \
        apt-transport-https \
        openssh-server \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd \
    && echo 'root:root' | chpasswd \
    && sed -ri "s/Port 22/Port ${SSH_PORT}/g" /etc/ssh/sshd_config \
    && sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe restricted multiverse partner" \
    && sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
    && wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -O - | sudo apt-key add - \
    && apt-get update \
    && apt-get install -y ros-kinetic-desktop-full \
    && rosdep init \
    && rosdep update \
    && echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN sh -c 'echo "deb [ arch=amd64 ] http://packages.dataspeedinc.com/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-dataspeed-public.list' \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FF6D3CDA \
    && apt-get update \
    && sh -c 'echo "yaml http://packages.dataspeedinc.com/ros/ros-public-'${ROS_DISTRO}'.yaml '${ROS_DISTRO}'" > /etc/ros/rosdep/sources.list.d/30-dataspeed-public-'${ROS_DISTRO}'.list' \
    && rosdep update \
    && apt-get install -y \
        ros-${ROS_DISTRO}-dbw-mkz \
        ros-${ROS_DISTRO}-cv-bridge \
        ros-${ROS_DISTRO}-pcl-ros \
        ros-${ROS_DISTRO}-image-proc \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y \
        python2.7 \
        python2.7-dev \
        python-pip \
    && pip2 install --no-cache-dir Cython \
    && apt-get install -y \
        python3 \
        python3-dev \
        python3-pip \
        protobuf-compiler \
        python3-pil \
        python3-lxml \
        python3-tk \
        libssl-dev \
        libffi-dev \
        python3-dev \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY startup.sh ${HOME}/
COPY supervisord.conf ${HOME}/

EXPOSE ${SSH_PORT}
EXPOSE ${VNC_PORT}

WORKDIR ${HOME}
ENTRYPOINT ["./startup.sh"]
