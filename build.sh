#!/bin/bash
# Author: Satish Gaikwad <satish@satishweb.com>
# For manual push to docker hub, pass "manual" as 2nd parameter to this script

##############
## INIT
##############
sDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
logFile=$sDir/build.log
image="satishweb/awscli"

# Get params
buildType=$1
imgPush=#2

##############
## Functions
##############

# Usage function
usage() {
    echo "Usage: $0 <BuildType> <ImagePush> "
    echo "      BuildType: command|shell  -- Optional (Def: all)"
    echo "      ImagePush: manual|auto -- Optional (Def: manual)"
    exit 1
}

# lets display usage and exit here if first parameter is help
[[ "$1" == "help" ]] && usage

# error check function
errCheck(){
    # $1 = errocode
    # $2 = msg
    # $3 = exit on fail
    if [ "$?" != "0" ]
        then
            echo "ERR| $2"
            # if $3 is set then exit with errorcode
            [[ $3 ]] && exit $1
    fi
}

# Docker Build function
dockerBuild(){
    # $1 = image type

    # Lets set appropriate tags based on buildType
    [[ "$1" == "command" ]] && imageTag=latest
    [[ "$1" == "shell" ]] && imageTag=shell-latest
    echo "INFO: Building $1 Image: $image:$imageTag ... (may take a while)"
    echo "      Logs are redirected to $logFile"
    docker build -t $image:$imageTag $1/>$1-$logFile 2>&1
    errCheck "$?" "Docker Build failed, please check $logfile" "exitOnFail"
    
    # Lets identify awscli command version and setup image tags
    awscliVer=$(docker run --rm -it $image:$imageTag --version|awk -F '[ /]' '{ print $2 }')

    # Lets set awscli version tag based on buildType
    [[ "$1" == "command" ]] && verTag=$awscliVer
    [[ "$1" == "shell" ]] && verTag=shell-$awscliVer

    if [[ $awscliVer == *.*.* ]]
        then
            echo "INFO: Creating tags..."
            docker tag $image $image:$verTag >/dev/null 2>&1
            errCheck "$?" "Tag creation failed"
        else
            echo "WARN: Could not determine awscli version, ignoring tagging..."
    fi

    # Lets create git tag and do checkin
    if [[ $awscliVer == *.*.* ]]
        then
            echo "INFO: Creating/Updating git tag"
            git tag -d $verTag| sed 's/^/| GIT: /'
            git tag $verTag| sed 's/^/| GIT: /'
            git push origin --tags| sed 's/^/| GIT: /'
    fi
}

##############
## Validations
##############

! [[ "$buildType" =~ ^(command|shell)$ ]] && buildType=all
! [[ "$ImagePush" =~ ^(manual|auto)$ ]] && imgPush=manual

##############
## Main method
##############

# Head
echo "INFO: Build Type: $buildType"
echo "INFO: Image Push $ImagePush"
echo "NOTE: Execute \"$0 help\" to know parameters list"
echo "------------------------------------------------"
# Lets do git pull
echo "INFO: Fetching latest codebase changes"
git checkout master| sed 's/^/| GIT: /'
git pull | sed 's/^/| GIT: /'

# Lets prepare docker image
echo "INFO: Removing all tags of image $image ..."
docker rmi -f $(docker images|grep "$image"|awk '{print $1":"$2}') >/dev/null 2>&1
errCheck "$?" "Docker images removal failed" "exitOnFail"
if [[ "$buildType" != "all" ]]
    then
        dockerBuild $BuildType
    else
        dockerBuild command
        dockerBuild shell
fi

# Lets do manual push to docker.
# To be used only if docker automated build process is failed
if [[ "$1" == "manual" ]]
    then
        echo "INFO: Logging in to Docker HUB... (Interactive Mode)"
        docker login
        errCheck "$?" "Docker login failed..." "exitOnFail"
        echo "INFO: Pushing build to Docker HUB..."
        docker push $image
        errCheck "$?" "Docker push failed..." "exitOnFail"
fi
