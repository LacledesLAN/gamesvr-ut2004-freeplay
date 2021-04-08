# Laclede's LAN Unreal Tournament 2004 Dedicated Freeplay Server

This repository is maintained by [Laclede's LAN](https://lacledeslan.com). Its contents are heavily tailored and tweaked for use at our charity LAN-Parties. For third-parties we recommend using this repo only as a reference example and then building your own using [gamesvr-ut2004](https://github.com/LacledesLAN/gamesvr-ut2004) as the base image for your customized server.

## Linux

[![linux/amd64](https://github.com/LacledesLAN/gamesvr-ut2004-freeplay/actions/workflows/build-linux-image.yml/badge.svg?branch=master)](https://github.com/LacledesLAN/gamesvr-ut2004-freeplay/actions/workflows/build-linux-image.yml)

### Download

```shell
docker pull lacledeslan/gamesvr-ut2004-freeplay;
```

### Run Self Tests

The image includes a test script that can be used to verify its contents. No changes or pull-requests will be accepted to this repository if any tests fail.

```shell
docker run -it --rm lacledeslan/gamesvr-ut2004-freeplay:latest /app/ll-tests/gamesvr-ut2004-freeplay.sh;
```

### Run simple interactive server

```shell
docker run -it --rm --net=host lacledeslan/gamesvr-ut2004-freeplay ./ucc-bin server DM-Rustatorium?game=XGame.xDeathMatch?AdminName=lladmin?AdminPassword=test123 -nohomedir -lanplay
```

## Getting Started with Game Servers in Docker

[Docker](https://docs.docker.com/) is an open-source project that bundles applications into lightweight, portable, self-sufficient containers. For a crash course on running Dockerized game servers check out [Using Docker for Game Servers](https://github.com/LacledesLAN/README.1ST/blob/master/GameServers/DockerAndGameServers.md). For tips, tricks, and recommended tools for working with Laclede's LAN Dockerized game server repos see the guide for [Working with our Game Server Repos](https://github.com/LacledesLAN/README.1ST/blob/master/GameServers/WorkingWithOurRepos.md). You can also browse all of our other Dockerized game servers: [Laclede's LAN Game Servers Directory](https://github.com/LacledesLAN/README.1ST/tree/master/GameServers).
