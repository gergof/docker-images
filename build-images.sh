#!/bin/bash

# log(message, level)
function log {
	if [ "$2" == "ERROR" ]; then
		PREFIX="\e[31mE "
	elif [ "$2" == "QUESTION" ]; then
		PREFIX="\e[34m? "
	elif [ "$2" == "DESTRUCTIVE" ]; then
		PREFIX="\e[41m!!! "
	elif [ "$2" == "INSTRUCTION" ]; then
		PREFIX="\e[30;43m"
	elif [ "$2" == "MARKER" ]; then
		PREFIX="\e[30;46m"
	elif [ "$2" == "INFO" ]; then
		PREFIX="\e[90m=> "
	else
		PREFIX="\e[32m=> "
	fi

	echo -e "${PREFIX}$1\e[0m"
}

# check_cmd(command)
function check_cmd {
	if ! command -v $1 &>/dev/null; then
		log "Command $1 not found. Please install it to continue" ERROR
		exit 1
	fi
}

# build_image(name, version, location, extra_args)
function build_image {
	check_cmd "docker"
	log "Building image $1 version $2 in $3"
	TAG="${REGISTRY}/$1:$2"
	docker build --pull -t $TAG --build-arg VERSION=$2 $4 $3
	if [ $? -ne 0 ]; then
		log "Error while building the image" ERROR
		exit 1
	else
		log "Image built: ${TAG}"
	fi
}

# push_image(name, version)
function push_image {
	check_cmd "docker"
	log "Pusing image $1:$2"
	TAG="${REGISTRY}/$1:$2"
	docker push $TAG
	if [ $? -ne 0 ]; then
		log "Error while pushing the image" ERROR
		exit 1
	else
		log "Image pushed"
	fi
}

# ask(question)
function ask {
	log "$1 [Y/n]" QUESTION
	read -n 1 -s RESP
	if [ "$RESP" == "y" ] || [ "$RESP" == "Y" ] || [ "$RESP" == "" ]; then
		return 0
	fi

	return 1
}

REGISTRY="registry.systest.eu"

log "Building docker images <="
log "Using registry: $REGISTRY" INFO

log "Loading versions"

while read -r line; do
	image="$(echo $line | cut -d '=' -f 1)"
	version="$(echo $line | cut -d '=' -f 2)"
	varname="${image}_version"
	export "${varname}=${version}"
	log "    ${varname} = ${!varname}"
done < versions.txt

log "Loading build list"

toBuild=""

if [ $# -gt 0 ]; then
	log "Overriding build list from command line" INFO
	toBuild="$@"
else
	toBuild="$(ls -d */ | tr -d '/')"
fi

log "Building images"

for image in $toBuild; do
	versionvar="${image}_version"
	imageName="$(echo $image | sed 's/_/-/g' | sed 's/__/\//g')"

	build_image "$imageName" "${!versionvar}" "./$image"
done

if ask "Would you like to push these images?"; then
	log "Pushing images"

	for image in $toBuild; do
		versionvar="${image}_version"
		imageName="$(echo $image | sed 's/_/-/g' | sed 's/__/\//g')"

		push_image "$imageName" "${!versionvar}"
	done
fi

log "Done"
