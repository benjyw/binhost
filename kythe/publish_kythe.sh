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

fileformat_line=`objdump -s --section .comment  ${KYTHE_REV_DIR}/indexers/cxx_indexer  | grep -o "file format .*"`
fileformat=${fileformat_line:12}

function copy_release_tarball() {
  if [ "${fileformat}" == "Mach-O 64-bit x86-64" ]; then
    PLATFORM="MacOS"
    # Unfortunately github raw pages doesn't handle symlinks the way we'd want it to, so we
    # have to copy the file for each MacOS version.
    MACOS_REVS=("10.12" "10.13")
    for MACOS_REV in ${MACOS_REVS[@]}; do
      TARBALL_PATH="kythe/mac/${MACOS_REV}/${REV}/${BASENAME}"
      mkdir -p `dirname ${TARBALL_PATH}`
      cp ${KYTHE_REV_RELEASE} ${TARBALL_PATH}
    done
  elif [ "${fileformat}" == "ELF64-x86-64" ]; then
    PLATFORM="Linux"
    TARBALL_PATH="kythe/linux/x86_64/${REV}/${BASENAME}"
    mkdir -p `dirname ${TARBALL_PATH}`
    cp ${KYTHE_REV_RELEASE} ${TARBALL_PATH}
  else
    echo "Unrecognized fileformat: ${fileformat}"
    exit 2
  fi
}

# We don't currently host the tarball because it's over 100MB, so GitHub won't have it.
# We probably don't need to anyway, as our production code consumes the various binaries
# it uses from the docker image, so it's not clear we even have a use for this.
# copy_release_tarball


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
