FROM ubuntu:16.04
MAINTAINER Anatolii Volkodav <volkodavav@gmail.com>

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
        telnet \
        bzip2 \
        unzip \
        software-properties-common \
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

COPY startup.sh ${HOME}/
COPY supervisord.conf ${HOME}/

EXPOSE ${SSH_PORT}
EXPOSE ${VNC_PORT}

WORKDIR ${HOME}
ENTRYPOINT ["./startup.sh"]
