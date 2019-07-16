#!/usr/bin/env bash
set -e
trap '>&2 printf "\n\e[01;31mError: Command \`%s\` on line $LINENO failed with exit code $?\033[0m\n" "$BASH_COMMAND"' ERR

## find directory where this script is located following symlinks if neccessary
readonly BASE_DIR="$(
  cd "$(
    dirname "$(
      (readlink "${BASH_SOURCE[0]}" || echo "${BASH_SOURCE[0]}") \
        | sed -e "s#^../#$(dirname "$(dirname "${BASH_SOURCE[0]}")")/#"
    )"
  )" >/dev/null \
  && pwd
)/.."

## if --push is passed as first argument to script, this will login to docker hub and push images
PUSH_FLAG=
if [[ "${1:-}" = "--push" ]]; then
  PUSH_FLAG=1
fi

## change into base directory and login to docker hub if neccessary
pushd ${BASE_DIR} >/dev/null
[[ $PUSH_FLAG ]] && docker login

## iterate over and build each version/variant combination
VERSION_LIST="${VERSION_LIST:-"8.2 8.2.1 latest"}"
VARIANT_LIST="${VARIANT_LIST:-"base mysql"}"

for BUILD_VERSION in ${VERSION_LIST}; do
  for BUILD_VARIANT in ${VARIANT_LIST}; do
    IMAGE_TAG="davidalger/jira-software:${BUILD_VERSION}"
    if [[ ${BUILD_VARIANT} != "base" ]]; then
      IMAGE_TAG+="-${BUILD_VARIANT}"
    else
      BUILD_VARIANT=
    fi

    export PHP_VERSION

    printf "\e[01;31m==> building ${IMAGE_TAG}\033[0m\n"
    export _BUILD_VERSION=${BUILD_VERSION}
    envsubst '${_BUILD_VERSION}' < ${BASE_DIR}/${BUILD_VARIANT}/Dockerfile | docker build -t "${IMAGE_TAG}" -

    [[ $PUSH_FLAG ]] && docker push "${IMAGE_TAG}"
  done
done
