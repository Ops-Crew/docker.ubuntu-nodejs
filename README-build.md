[![Standard Version](https://img.shields.io/badge/release-standard%20version-brightgreen.svg?style=plastic)](https://github.com/conventional-changelog/standard-version) [![License Badge](https://images.microbadger.com/badges/license/tbaltrushaitis/ubuntu-nodejs.svg)](https://microbadger.com/images/tbaltrushaitis/ubuntu-nodejs "") [![Contributors List](https://img.shields.io/github/contributors/tbaltrushaitis/mp3web.svg)](https://github.com/tbaltrushaitis/mp3web/graphs/contributors)

# Docker Image #

![Ubuntu Logo](https://raw.githubusercontent.com/docker-library/docs/01c12653951b2fe592c1f93a13b4e289ada0e3a1/ubuntu/logo.png)

`ubuntu` `nodejs` `ubuntu-nodejs` `nodejs-dockerized`

---

Docker Container with [Ubuntu Linux](https://www.ubuntu.com "Ubuntu official") and [Node.js](https://nodejs.org "Node Foundation") environment preinstalled.

---

[![dockeri.co](http://dockeri.co/image/tbaltrushaitis/ubuntu-nodejs)](https://hub.docker.com/r/tbaltrushaitis/ubuntu-nodejs/)

---

### Usage ###

#### Build from Dockerfile tagged with $TAG ####

```shell
$ docker build -f Dockerfile --no-cache --force-rm -t tbaltrushaitis/ubuntu-nodejs:8.0.0 .
```

```shell
$ HUB_USER=tbaltrushaitis
$ HUB_REPO=ubuntu-nodejs
$ NODE_VERSION=8.0.0

$ HUB_IMAGE=${HUB_USER}/${HUB_REPO}
$ TAG="v${NODE_VERSION}"

$ docker build -f Dockerfile --no-cache --force-rm -t ${HUB_IMAGE}:${TAG} .
$ docker build -f Dockerfile --force-rm -t ${HUB_IMAGE}:${TAG} .
```

#### Remove Unused Images ####

```shell
$ IMAGES_LIST=$(docker images -a | grep "<none>" | awk '{print $3}')
$ docker rmi -f ${IMAGES_LIST}
```

---

### Useful Info ###

 - [GitHub / Basic writing and formatting syntax](https://help.github.com/articles/basic-writing-and-formatting-syntax/)
 - [BitBucket Markdown Howto](https://bitbucket.org/tutorials/markdowndemo)
 - [Creating an Automated Build](https://docs.docker.com/docker-hub/builds/)
 - [Linking containers](https://docs.docker.com/engine/userguide/networking/default_network/dockerlinks.md)
 - [Cross-host linking containers](https://docs.docker.com/engine/admin/ambassador_pattern_linking.md)

---

:scorpius:
