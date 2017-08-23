#!/usr/bin/env bash


ggrep -V >/dev/null 2>&1 || {
  echo >&2 "I require ggrep but it's not installed.  Please install using 'brew install grep'. Aborting.";
  exit 1;
}

SNOWCHAIN_REPO=~/src/snowchain/

VERSION_FILE="${SNOWCHAIN_REPO}/src/python/snowchain/version.py"

VERSION=`ggrep -P -o "(?<=VERSION = ')\d+\.\d+\.\d+" ${VERSION_FILE}`

DISTDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'distdir'`

PYPI_ROOT='pypi'

INDEX_ROOT='doc'

echo "Building distribution for version ${VERSION} into ${DISTDIR}."

pushd ${SNOWCHAIN_REPO}
./pants --pants-distdir=${DISTDIR} setup-py --recursive src/python/snowchain/workflow
popd


echo "Publishing version ${VERSION} to binhost."

for FILENAME in `ls ${DISTDIR}`; do
  ARCHIVE_PATH="${DISTDIR}/${FILENAME}"
  PROJECT=`echo ${FILENAME} | ggrep -P -o ".*(?=-${VERSION}.tar.gz)" | tr . -`
  PROJECT_DIR="${PYPI_ROOT}/${PROJECT}"
  mkdir -p ${PROJECT_DIR}
  cp "${ARCHIVE_PATH}" ${PROJECT_DIR}
done


# We use Github Pages' ability to serve pages from just the /doc subdir to get it to
# serve the PyPi index.
INDEX_ROOT="docs"

function index_dir() {
  local DIR_TO_INDEX="$1"

  local INDEX_CONTENT=""
  for ENTRY in `ls ${DIR_TO_INDEX}`; do
    local ENTRY_PATH="${DIR_TO_INDEX}/${ENTRY}"
    local ANCHOR=""
    if [[ -d "${ENTRY_PATH}" ]]; then
      ANCHOR="${ENTRY}/index.html"  # Relative path from this index file.
    else
      ANCHOR="https://raw.githubusercontent.com/benjyw/binhost/master/${ENTRY_PATH}"  # Absolute path to file content.
    fi
    local INDEX_CONTENT="${INDEX_CONTENT}<br><a href=\"${ANCHOR}\">${ENTRY}</a>"
  done

  local INDEX_DIR="${INDEX_ROOT}/${DIR_TO_INDEX}"
  local INDEX_FILE="${INDEX_DIR}/index.html"
  mkdir -p ${INDEX_DIR}
  echo "<html><body>${INDEX_CONTENT}</body></html>" > ${INDEX_FILE}

  # Note that we can't recurse in the loop above, because even local vars are visible in all
  # called functions, which would mess up INDEX_CONTENT.  So we must have a separate loop here.
  for ENTRY in `ls ${DIR_TO_INDEX}`; do
    local ENTRY_PATH="${DIR_TO_INDEX}/${ENTRY}"
    if [[ -d "${ENTRY_PATH}" ]]; then
      index_dir ${ENTRY_PATH}
    fi
  done
}

index_dir ${PYPI_ROOT}


git add --all
git commit -m "snowchain.workflow ${VERSION}"


echo "Done! (Don't forget to manually verify and then push the commit.)"
