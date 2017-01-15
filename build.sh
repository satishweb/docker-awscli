#!/bin/bash
# Author: Satish Gaikwad <satish@satishweb.com>
# For manual push to docker hub, pass "manual" as parameter to this script
sDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
logFile=$sDir/build.log
image="satishweb/awscli"

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

# Lets do git pull
echo "INFO: Fetching latest codebase changes"
git pull | sed 's/^/| GIT: /'

# Lets prepare docker image
echo "INFO: Removing all tags of image $image ..."
docker rmi -f $(docker images|grep "$image"|awk '{print $1":"$2}') >/dev/null 2>&1
errCheck "$?" "Docker images removal failed" "exitOnFail"
echo "INFO: Building Image: $image ... (may take a while)"
echo "      Logs are redirected to $logFile"
docker build -t "$image" .>$logFile 2>&1
errCheck "$?" "Docker Build failed, please check $logFile" "exitOnFail"

# Lets identify awscli command version and setup image tags
awscliVer=$(docker run --rm -it $image --version|awk -F '[ /]' '{ print $2 }')
if [[ $awscliVer == *.*.* ]]
    then
        echo "INFO: Creating tags..."
        docker tag $image $image:$awscliVer >/dev/null 2>&1
        errCheck "$?" "Tag creation failed"
    else
        echo "WARN: could not determine awscli version, ignoring tagging..."
fi

# Lets create git tag and do checkin
if [[ $awscliVer == *.*.* ]]
    then
        echo "INFO: Creating git tag"
        git tag -d $awscliVer| sed 's/^/| GIT: /'
        git tag $awscliVer| sed 's/^/| GIT: /'
        git push origin --tags| sed 's/^/| GIT: /'
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
