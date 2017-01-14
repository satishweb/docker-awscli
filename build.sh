#!/bin/bash
image="satishweb/awscli"
echo "Building Image: $image ..."
docker build -t "$image" .
if [ "$?" != "0" ]
 then
    echo "Docker Build command failed"
    exit 2
fi
