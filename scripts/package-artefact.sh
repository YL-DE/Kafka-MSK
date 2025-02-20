#!/bin/bash
set -euo pipefail

FILES_FOLDERS_TO_PACKAGE=$1

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ROOT_DIR=${SCRIPTS_DIR}/..
ARTEFACT_DIR=${ROOT_DIR}/artefact
TEMP_DIR=${ROOT_DIR}/temp
ARTEFACT_VERSION=package.zip

[ -d ${ARTEFACT_DIR} ] || mkdir ${ARTEFACT_DIR}
[ -d ${TEMP_DIR} ] || mkdir ${TEMP_DIR}

for item in ${FILES_FOLDERS_TO_PACKAGE}
do
  echo "item is $item";
  if [ -d ${ROOT_DIR}/$item ]; then
    echo "Directory ${ROOT_DIR}/$item exists, copying to artefact directory"
    cp -r ${ROOT_DIR}/$item $TEMP_DIR
  elif [ -f ${ROOT_DIR}/$item ]; then
    echo "file ${ROOT_DIR}/$item exists, copying to artefact directory"
    cp ${ROOT_DIR}/$item $TEMP_DIR
  else
    echo "file ${ROOT_DIR}/$item does not exist, please check and rectify.."
  fi
done

cd ${TEMP_DIR}; zip -r $ARTEFACT_VERSION *;
cp ${TEMP_DIR}/$ARTEFACT_VERSION $ARTEFACT_DIR
rm -rf $TEMP_DIR; cd ${ROOT_DIR}