#!/bin/bash
##  ------------------------------------------------------------------------  ##
##                            Commonly Used Functions                         ##
##  ------------------------------------------------------------------------  ##

function log () {
    printf "$(date +"%Y%m%d%H%M%S")%s\n" "$@";
}

function info () {
    echo -e "\n${BBlue}INFO:$NC" "${@}";
}

function error () {
    echo -e "\n${BRed}ERROR:$NC" "${@}" 1>&2;
}

function fatal () {
    printf "**********\n"
    printf "%s\n" "$@"
    printf "**********\n"
    RETVAL=1
}

function loadEnv () {
    local ENVD=$1
    ENVD=${ENVD:-.}
    for ENVF in `ls ${ENVD}/.env*`
        do
            if [ -f "${ENVF}" ]; then
               . "${ENVF}";
                printf "ENV: exported vars from [${ENVF}]:\n";
                cat ${ENVF} | sed -e "s/^/\t/g"
            fi
        done
}

##  ------------------------------------------------------------------------  ##
##                                   CLEANUP                                  ##
##  ------------------------------------------------------------------------  ##

##  Cleanup images
function cleanImages () {
    info Cleanup images
    docker rmi $(docker images | grep '<none>' | awk '{print $3}')
}

##  Clean up exited docker containers
function cleanContainers () {
    info Clean up exited docker containers
    # docker rm -v $(docker ps -aq -f status=exited)
    docker container prune -f
}

##  Remove “dangling” volumes - volumes that are no longer referenced by a container
function cleanVolumes () {
    info Remove “dangling” volumes
    docker volume prune -f
}

##  Clean up ALL
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

