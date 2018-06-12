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
  echo "Usage: $0 <kythe_version> (e.g., vXX.YY.ZZ-toolchainNNN-HHHHHHHHHHHH)"
  exit 1
fi

echo "publishing ${REV} to binhost"

KYTHE_REV_RELEASE="${HOME}/kythe_releases/kythe-${REV}.tar.gz"
KYTHE_REV_DIR="${HOME}/kythe_releases/kythe-${REV}"

BASENAME="kythe.tar.gz"

if [ `uname` == "Darwin" ];
then
  # Unfortunately github raw pages doesn't handle symlinks the way we'd want it to, so we
  # have to copy the file for each MacOS version.
  MACOS_REVS=("10.12" "10.13")
  for MACOS_REV in ${MACOS_REVS[@]}; do
    TARBALL_PATH="kythe/mac/${MACOS_REV}/${REV}/${BASENAME}"
    mkdir -p `dirname ${TARBALL_PATH}`
    cp ${KYTHE_REV_RELEASE} ${TARBALL_PATH}
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

copy_jar "extractors/javac_extractor"
copy_jar "indexers/java_indexer"
copy_jar "indexers/jvm_indexer"

git add --all
git commit -m "Kythe release ${REV}"
