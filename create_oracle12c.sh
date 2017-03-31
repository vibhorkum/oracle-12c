#!/bin/bash
C_NAME=$1

docker run --privileged=true --shm-size=6g  --publish-all=true --interactive=false --tty=true -v /Users/${USER}/Desktop:/Desktop --hostname=${C_NAME} --detach=true --name=${C_NAME} oracle-12c:latest
