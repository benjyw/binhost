#!/usr/bin/env bash

# Note: Run this from the binhost repo root.

# Since Kythe currently does not do regular releases, and in any case doesn't publish their
# releases, we build and publish our own, under custom version numbers.
#
# See README.md for how to run this script.

set -e

REV=$1
if [ -z "$REV" ];
then
  echo "Usage: $0 <kythe_version> (e.g., vXX.YY.ZZ.5-snowchainNNN-HHHHHHHHHHH)"
  exit 1
fi

echo "publishing ${REV} to binhost"

KYTHE_REV_RELEASE="${HOME}/kythe_releases/kythe-${REV}.tar.gz"
KYTHE_REV_DIR="${HOME}/kythe_releases/kythe-${REV}"

BASENAME="kythe.tar.gz"

if [ `uname` == "Darwin" ];
then
  EARLIEST_MACOS_REV="10.11"
  OTHER_MACOS_REVS=("10.12" "10.13")
  TARBALL_PATH="kythe/mac/${EARLIEST_MACOS_REV}/${REV}/${BASENAME}"
  mkdir -p `dirname ${TARBALL_PATH}`
  cp ${KYTHE_REV_RELEASE} ${TARBALL_PATH}
  for MACOS_REV in ${OTHER_MACOS_REVS[@]}; do
    DIR="kythe/mac/${MACOS_REV}/${REV}"
    mkdir -p ${DIR}
    pushd ${DIR} > /dev/null
    ln -s "../../${EARLIEST_MACOS_REV}/${REV}/${BASENAME}" ${BASENAME}
    popd > /dev/null
  done
else
  TARBALL_PATH="kythe/linux/x86_64/${REV}/${BASENAME}"
  mkdir -p `dirname ${TARBALL_PATH}`
  cp ${KYTHE_REV_RELEASE} ${TARBALL_PATH}
fi


function copy_jar() {
  local SRC="$1"
  local ARTIFACT=$(basename "$1")
  local OUTPUT_DIR="kythe/${ARTIFACT}/${REV}"
  mkdir -p ${OUTPUT_DIR}
  cp "${KYTHE_REV_DIR}/${SRC}.jar" "${OUTPUT_DIR}/${ARTIFACT}-${REV}.jar"
}

#copy_jar "extractors/javac_extractor"
#copy_jar "indexers/java_indexer"

#git add --all
#git commit -m "Kythe release ${REV}"
