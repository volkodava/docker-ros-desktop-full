# docker-ros-desktop-full

VNC/SSH ROS desktop inside a docker container.

### Getting up and running
```bash
docker run -it --rm -p 5900:5900 -p 2222:2222 anatoliiv/docker-ros-desktop-full:latest
```

### Build docker image

1. Install docker on OS of your choice by following instructions at [Run Docker anywhere](https://docs.docker.com/#run-docker-anywhere)

2. Build docker image using next command:
```bash
make build
```

3. Run docker image using next command:
```bash
make start
```

4. Connect to docker image can be done:
    - via `VNC` viewer ([VNC Connect](https://www.realvnc.com/en/connect/download/viewer/)) using next address: `localhost:5900`
    - via `SSH` using next command (password: `root`): 
```bash
ssh root@localhost -p 2222
```

5. Stop docker image using next command:
```bash
make stop
```

### Install a package

1. Before install a package you need to re-synchronize the package index files from their sources using next command:
```bash
apt-get update
```

2. To install a package use next command:
```bash
apt-get install -y package
```


# Issues

- If you can't connect to `ssh` try the following command:
```bash
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@localhost -p 2222
```

- For other issues check `/var/log` directory inside a container
