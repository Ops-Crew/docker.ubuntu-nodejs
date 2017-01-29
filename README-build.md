# Docker Image [![](https://images.microbadger.com/badges/version/tbaltrushaitis/ubuntu-nodejs.svg)](https://microbadger.com/images/tbaltrushaitis/ubuntu-nodejs) [![](https://images.microbadger.com/badges/image/tbaltrushaitis/ubuntu-nodejs.svg)](https://microbadger.com/images/tbaltrushaitis/ubuntu-nodejs)

![Ubuntu Logo](https://raw.githubusercontent.com/docker-library/docs/01c12653951b2fe592c1f93a13b4e289ada0e3a1/ubuntu/logo.png)

`ubuntu-nodejs`

--------

### Build ###

#### Build from Dockerfile tagged with $TAG ####

```
REPO="tbaltrushaitis/ubuntu-nodejs"
VERSION=6.9.1
TAG="v${VERSION}"
docker build -f Dockerfile --no-cache --force-rm -t tbaltrushaitis/ubuntu-nodejs:6.9.1 .
docker build -f Dockerfile --no-cache --force-rm -t ${REPO}:${TAG} .
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
