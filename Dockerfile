##  ================================================================================  ##
##                              Node.js Application                                   ##
##  ================================================================================  ##

##  Source Image
##  --------------------------------------------------------------------------------  ##
FROM buildpack-deps:jessie

##  Build-time metadata as defined at http://label-schema.org
##  --------------------------------------------------------------------------------  ##
ARG BUILD_DATE
ARG VCS_URL
ARG VCS_REF
ARG VERSION

##  Image Labels Metadata
##  --------------------------------------------------------------------------------  ##
LABEL   com.docker.hub.ubuntu-nodejs.maintainer.name="Kevix"                    \
        com.docker.hub.ubuntu-nodejs.maintainer.mail="kevix.ultra@gmail.com"    \
        com.docker.hub.ubuntu-nodejs.description="Dockerized Node.js server"    \
        com.docker.hub.ubuntu-nodejs.build-date=${BUILD_DATE}                   \
        com.docker.hub.ubuntu-nodejs.vcs-url=${VCS_URL}                         \
        com.docker.hub.ubuntu-nodejs.vcs-ref=${VCS_REF}                         \
        com.docker.hub.ubuntu-nodejs.dockerfile.version=${VERSION}              \
        com.docker.hub.ubuntu-nodejs.is-production="true"

##  Environment Variables
##  --------------------------------------------------------------------------------  ##
ENV NPM_CONFIG_LOGLEVEL=${NPM_CONFIG_LOGLEVEL:-info} \
    NODE_VERSION=${NODE_VERSION:-7.4.0}              \
    SVC_USER=${SVC_USER:-node}

##  Create the node.js system user
##  --------------------------------------------------------------------------------  ##
RUN groupadd -r ${SVC_USER}   \
 && useradd -r -g ${SVC_USER} \
            --shell /bin/bash \
            --create-home     \
            ${SVC_USER}       \
    \
##  gpg keys listed at https://github.com/nodejs/node   \ 
##  --------------------------------------------------------------------------------  ##    \ 
#RUN set -ex #  \ 
 && set -ex     \
 && for key in  \
        9554F04D7259F04124DE6B476D5A82AC7E37093B \
        94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
        0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
        FD3A5288F042B6850C66B31F09FE44734EB7990E \
        71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
        DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
        B9AE9905FFD7803F25714661B63B535A4C206CA9 \
        C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do  \
        gpg --keyserver ha.pool.sks-keyservers.net \
            --recv-keys "$key";                    \
    done

##  Node.js Setup
##  --------------------------------------------------------------------------------  ##
RUN curl -SLO "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" \
 && curl -SLO "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt.asc"                     \
 && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc                            \
 && grep "node-v${NODE_VERSION}-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c -             \
 && tar -xJf node-v${NODE_VERSION}-linux-x64.tar.xz -C /usr/local --strip-components=1          \
 && rm "node-v${NODE_VERSION}-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt               \
 && ln -s /usr/local/bin/node /usr/local/bin/nodejs                                             \
 && printf "\n\n\n\tDEPLOYED - \t Node.js:$(node -v) \n\n\n"                                    \
    \
##  Tools Setup \
##  --------------------------------------------------------------------------------  ##    \ 
## RUN apt-get -q update         ## \ 
 && apt-get -q update               \
 && apt-get -y install              \
            --no-install-recommends \
            curl                    \
            git                     \
            wget                    \
 && apt-get clean                   \
 && rm -rf /var/lib/apt/lists/*     \
 && printf "\n\n\tDEPLOYED - \t TOOLS \n\n";  # /**/

##  Communication
##  --------------------------------------------------------------------------------  ##
USER ${SVC_USER}

## Set /usr/bin/node as the Dockerized entry-point Application
#ENTRYPOINT ["node"];
#CMD ["--print"];
