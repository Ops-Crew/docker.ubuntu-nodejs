#!/bin/bash
##  ------------------------------------------------------------------------  ##
##                      f.sh:   Commonly Used Functions                       ##
##  ------------------------------------------------------------------------  ##


##  ------------------------------------------------------------------------  ##
##                                    LOGGERS                                 ##
##  ------------------------------------------------------------------------  ##
function log () {
  printf "$(date +"%Y%m%d%H%M%S")\t%s\n" "$@";
}


function info () {
  echo -en "\n${BBlue}INFO:${NC}" "${@}";
}


function error () {
  echo -en "\n${BRed}ERROR:${NC}" "${@}" 1>&2;
}


function fatal () {
  printf "**********\n"
  printf "%s\n" "$@"
  printf "**********\n"
  RETVAL=1
}


function log2 {
  printf "DATETIME:\t[${D_T}]\n" > "${APP_LOG}"
  printf "APP_NAME:\t[${APP_NAME}]\n" >> "${APP_LOG}"
  printf "APP_TITLE:\t[${APP_TITLE}]\n" >> "${APP_LOG}"
  printf "APP_DOMAIN:\t[${APP_DOMAIN}]\n" >> "${APP_LOG}"
  printf "DB_HOST:\t[${DB_HOST}]\n" >> "${APP_LOG}"
  printf "DB_NAME:\t[${DB_NAME}]\n" >> "${APP_LOG}"
  printf "DB_USER:\t[${DB_USER}]\n" >> "${APP_LOG}"
  printf "DB_PASS:\t[${DB_PASS}]\n" >> "${APP_LOG}"
  printf "DB_TAG:\t[${DB_TAG}]\n" >> "${APP_LOG}"

  tail -10 "${APP_LOG}"
}


##  ------------------------------------------------------------------------  ##
##              Load Environment Variables From .env Files
##  ------------------------------------------------------------------------  ##

function loadEnv () {
  local ENVD=$1
  ENVD=${ENVD:-.}
  for ENVF in `ls ${ENVD}/.env*`
    do
      if [ -f "${ENVF}" ]; then
       . "${ENVF}";
        echo -e "${BWhite}ENV: exported vars from [${ENVF}]:\n";
        cat "${ENVF}" | sed -e "s/^/\t/g"
      fi
    done
}


##  ------------------------------------------------------------------------  ##
##                                   CLEANUP                                  ##
##  ------------------------------------------------------------------------  ##

##  Images
function cleanImages () {
    fatal Cleanup images
    docker rmi $(docker images | grep '<none>' | awk '{print $3}')
}


##  Exited Docker Containers
function cleanContainers () {
    error Clean up exited docker containers
    docker container prune -f
}


##  “dangling” volumes - not referenced by a container
function cleanVolumes () {
    info Remove “dangling” volumes
    docker volume prune -f
}


##  ALL Cleanup Steps Together
function cleanup () {
    info Clean up ALL
    cleanContainers
    cleanImages
    cleanVolumes
}


##  ------------------------------------------------------------------------  ##
##                               META Information                             ##
##  ------------------------------------------------------------------------  ##

function metaInfo () {
  Image=$1;
  log "\n\tmetaInfo([$1])\n";

  docker inspect -f '
    ##
    ## Docker Metadata
    ##

    - Image ID: {{ "\t" }} {{ .Id }}
    - Created: {{ "\t" }} {{ .Created }}
    - Arch: {{ "\t" }} {{ .Os }}/{{ .Architecture }}
    - Domainname: {{ "\t" }} {{ .Config.Domainname }}
    - Hostname: {{ "\t" }} {{ .Config.Hostname }}
    - Labels:{{range $e,$v := .Config.Labels}} {{ "\n\t\t" }} LABEL {{ $e }}{{ "=" }}{{ $v }} {{end}}
    - Environment:{{range $e,$v := .Config.Env}} {{ "\n\t\t" }} ENV {{ $v }} {{end}}
    {{if .Config.OnBuild}}ONBUILD {{json .Config.OnBuild}} {{end}}
    {{range $e,$v := .Config.Volumes}}VOLUME {{json $e}} {{end}}
    {{if .Config.User}}USER {{json .Config.User}} {{end}}
    {{if .Config.WorkingDir}}WORKDIR {{.Config.WorkingDir}} {{end}}
    {{if .Config.Entrypoint }}ENTRYPOINT {{ json .Config.Entrypoint}} {{ end }}
    {{if .Config.Cmd}}CMD {{json .Config.Cmd}} {{end}}
    {{with .Config}}{{ "\n\n" }}FULL_CONFIG: {{json .}} {{end}}
    ' "${Image}"
}

#        {{if .Config.ExposedPorts}}{{range $e,$v := .Config.ExposedPorts}}EXPOSE {{json $e}}{{end}}{{end}}
