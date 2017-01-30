# Docker Image [![](https://images.microbadger.com/badges/version/tbaltrushaitis/ubuntu-nodejs.svg)](https://microbadger.com/images/tbaltrushaitis/ubuntu-nodejs) [![](https://images.microbadger.com/badges/image/tbaltrushaitis/ubuntu-nodejs.svg)](https://microbadger.com/images/tbaltrushaitis/ubuntu-nodejs)

![Ubuntu Logo](https://raw.githubusercontent.com/docker-library/docs/01c12653951b2fe592c1f93a13b4e289ada0e3a1/ubuntu/logo.png)

`ubuntu-nodejs`

--------

### Build ###

#### Build from Dockerfile tagged with $TAG ####

```
docker build -f Dockerfile --no-cache --force-rm -t tbaltrushaitis/ubuntu-nodejs:7.4.0 .
```

```
HUB_USER=tbaltrushaitis
HUB_REPO=ubuntu-nodejs
NODE_VERSION=7.4.0

HUB_IMAGE=${HUB_USER}/${HUB_REPO}
TAG="v${NODE_VERSION}"

docker build -f Dockerfile --no-cache --force-rm -t ${HUB_IMAGE}:${TAG} .
docker build -f Dockerfile --force-rm -t ${HUB_IMAGE}:${TAG} .
```

#### Remove Unused Images ####

```
IMAGES_LIST=$(docker images -a | grep "<none>" | awk '{print $3}')
docker rmi -f ${IMAGES_LIST}
```

--------

### Authors and Contributors ###

##### Development team #####
  + @tbaltrushaitis
  + @soldat79_001

##### Contributors list #####
  + @tbaltrushaitis
  + @maybeyou?

--------

### More Useful Info ###

 - [Markdown Howto](https://bitbucket.org/tutorials/markdowndemo)
 - [Linking containers](https://docs.docker.com/engine/userguide/networking/default_network/dockerlinks.md)
 - [Cross-host linking containers](https://docs.docker.com/engine/admin/ambassador_pattern_linking.md)
 - [Creating an Automated Build](https://docs.docker.com/docker-hub/builds/)
