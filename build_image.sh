#!/bin/bash

# set -x

HOMEDIR_GIT=/home/erik/adelerhof.eu

REPO_LIST='git@github.com:adelerhof/httpstatus.git'

function checkout_code {

[ -d $HOMEDIR_GIT ] || /bin/mkdir -p $HOMEDIR_GIT
pushd ${HOMEDIR_GIT}
# Loop over the repos of appfactory
for I in ${REPO_LIST}
do
	# Determine the directory of the cloned repo
	DIR=$(echo $I |cut -d\/ -f 2- | sed 's/.git$//')
	echo "${I} ${DIR}"

	# Check or the directory exists and is not a sybolic link
	if [ -d ${DIR} -a  ! -h ${DIR} ]
	then
		# Update the contect of the directory
		pushd ${DIR}
		git checkout ${ENVIRONMENT}
		git pull
		git submodule sync --recursive
		git submodule foreach git checkout master
		git submodule foreach git pull origin master
		popd
	else
		# Delete the symbolid link (when it's there) and make a fresh clone
	    rm -f ${DIR}
		git clone --recursive $I
	fi
	echo
done
popd
}

function build_image {

  TAG=$(date +%Y%m%d%H%M%S)
  # Build the Docker image date
  docker build . --file src/Teapot.Web/Dockerfile --tag ghcr.io/adelerhof/httpstatus-${ENVIRONMENT}:${TAG}
  docker build . --file src/Teapot.Web/Dockerfile --tag ghcr.io/adelerhof/httpstatus-${ENVIRONMENT}:latest
  docker build . --file src/Teapot.Web/Dockerfile --tag harbor.adelerhof.eu/httpstatus/httpstatus-${ENVIRONMENT}:${TAG}
  docker build . --file src/Teapot.Web/Dockerfile --tag harbor.adelerhof.eu/httpstatus/httpstatus-${ENVIRONMENT}:latest

}

function push_image {

  # Push the Docker image date
  docker push ghcr.io/adelerhof/httpstatus-${ENVIRONMENT}:${TAG}
  docker push ghcr.io/adelerhof/httpstatus-${ENVIRONMENT}:latest
  docker push harbor.adelerhof.eu/httpstatus/httpstatus-${ENVIRONMENT}:${TAG}
  docker push harbor.adelerhof.eu/httpstatus/httpstatus-${ENVIRONMENT}:latest

}

function cleanup {

  # Remove the Docker images locally
  docker rmi -f ghcr.io/adelerhof/httpstatus-${ENVIRONMENT}:${TAG}
  docker rmi -f ghcr.io/adelerhof/httpstatus-${ENVIRONMENT}:latest
  docker rmi -f harbor.adelerhof.eu/httpstatus/httpstatus-${ENVIRONMENT}:${TAG}
  docker rmi -f harbor.adelerhof.eu/httpstatus/httpstatus-${ENVIRONMENT}:latest

}

function deploy_prd {

	ENVIRONMENT=main

	checkout_code
	build_image
	push_image
	cleanup
}

# Script options
case $1 in
        deploy_prd)
        $1
        ;;
        *)
       echo $"Usage : $0 {deploy_prd}"
       exit 1
       ;;
esac
