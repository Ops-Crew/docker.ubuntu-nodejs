##  ========================================================================  ##
##                              Node.js Application                           ##
##  ========================================================================  ##

##  Source Image
##  ------------------------------------------------------------------------  ##
FROM buildpack-deps:jessie

##  Build-time metadata as defined at http://label-schema.org
##  ------------------------------------------------------------------------  ##
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION
ARG NODE_VERSION
ARG SVC_USER

##  Image Labels Metadata
##  ------------------------------------------------------------------------  ##
LABEL org.label-schema.schema-version="1.0"                     \
      org.label-schema.build-date=${BUILD_DATE}                 \
      org.label-schema.name="Ubuntu + Node.js"                  \
      org.label-schema.description="Dockerized Node.js Server"  \
      org.label-schema.version=${VERSION:-latest}               \
      org.label-schema.vendor="Baltrushaitis Tomas"             \
      org.label-schema.vcs-ref=${VCS_REF}                       \
      org.label-schema.vcs-url=${VCS_URL}                       \
      org.label-schema.is-production="true"                     \
      org.label-schema.license="MIT"                            \
      org.label-schema.maintainer.mail="tbaltrushaitis@gmail.com"

##  ------------------------------------------------------------------------  ##
##  Environment Variables
##  ------------------------------------------------------------------------  ##
ENV NPM_CONFIG_LOGLEVEL=${NPM_CONFIG_LOGLEVEL:-info}  \
    NODE_VERSION=${NODE_VERSION:-9.11.2}              \
    SVC_USER=${SVC_USER:-node}

##  ------------------------------------------------------------------------  ##
##  Execute prerequisites in ONE RUN command
##  ------------------------------------------------------------------------  ##
RUN \
\
##  Create the node.js system user \
##  ------------------------------------------------------------------------  ## \
  groupadd  --system            \
            --force             \
            --gid 1000          \
            "${SVC_USER}"       \
 && useradd --system            \
            --uid 1000          \
            --gid "${SVC_USER}" \
            --shell /bin/bash   \
            --create-home       \
            "${SVC_USER}"       \
\
##  GPG keys listed at https://github.com/nodejs/node#release-team  \
##  ------------------------------------------------------------------------  ## \
 && set -ex                                     \
 && for key in                                  \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5    \
    FD3A5288F042B6850C66B31F09FE44734EB7990E    \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1    \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D    \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8    \
    B9AE9905FFD7803F25714661B63B535A4C206CA9    \
    56730D5401028683275BD23C23EFEFE93C4CFFFE    \
    77984A986EBC2AA786BC0F66B01FBB92821C587A    \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600    \
; do                                            \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ||         \
    gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ;                \
  done                                          \
\
##  Updates Setup                   \
##  ------------------------------------------------------------------------  ## \
 && apt-get -q update               \
            --assume-yes            \
 && echo -e "\n\tDEPLOYED: \t UPDATES \n" \
\
##  Tools Setup                     \
##  ------------------------------------------------------------------------  ## \
 && apt-get install                 \
            --assume-yes            \
            --no-install-recommends \
            curl                    \
            mc                      \
            wget                    \
            git                     \
            htop                    \
 && echo -e "\n\tDEPLOYED: \t TOOLS \n" \
\
##  Cleanup                         \
##  ------------------------------------------------------------------------  ## \
 && apt-get autoremove              \
 && apt-get clean                   \
 && rm -rf /var/lib/apt/lists/*     \
 && echo -e "\n\tCLEANED: \t APT CACHES \n" \
\
##  Node.js Setup                 */\
##  ------------------------------------------------------------------------  ## \
 && ARCH= && dpkgArch="$(dpkg --print-architecture)" \
 && case "${dpkgArch##*-}" in                        \
      amd64) ARCH='x64';;                            \
      ppc64el) ARCH='ppc64le';;                      \
      s390x) ARCH='s390x';;                          \
      arm64) ARCH='arm64';;                          \
      armhf) ARCH='armv7l';;                         \
      i386) ARCH='x86';;                             \
      *) echo "unsupported architecture"; exit 1 ;;  \
    esac                                             \
 && curl -fsSLO --compressed "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}.tar.xz" \
 && curl -fsSLO --compressed "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt.asc"      \
 && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc                            \
 && grep " node-v${NODE_VERSION}-linux-${ARCH}.tar.xz\$" SHASUMS256.txt | sha256sum -c -        \
 && tar -xJf "node-v${NODE_VERSION}-linux-${ARCH}.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
 && rm "node-v${NODE_VERSION}-linux-${ARCH}.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt           \
 && ln -s /usr/local/bin/node /usr/local/bin/nodejs                                             \
 && echo -e "\n\n\tDEPLOYED: \t Node.js:$(node -v) for linux-${ARCH} \n\n"                      \
\
##  System Enhacements Pack         \
##  ------------------------------------------------------------------------  ## \
 && cd /tmp/                        \
 && APP_NAME=bash-files             \
 && git clone https://github.com/tbaltrushaitis/${APP_NAME}.git \
 && cd ${APP_NAME}                  \
 && make                            \
 && cd ..                           \
 && rm -rf ${APP_NAME}              \
 && echo -e "\n\tDEPLOYED: \t ENHANCEMENTS \n"

##  Communication
##  ------------------------------------------------------------------------  ##
USER ${SVC_USER}

## Set /usr/bin/node as the Dockerized entry-point Application
ENTRYPOINT ["/usr/local/bin/node"];

# CMD ["node", "-v"];
