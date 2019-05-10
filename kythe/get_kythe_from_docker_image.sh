#!/usr/bin/env bash

# We have a Dockerfile that builds Kythe, ensuring a stable, consistent environment.
# This script grabs the Kythe release from the resulting Docker image.
#
# Note: Run this from the binhost repo root. Assumes you have appropriate AWS privileges to pull from
# the ACR repo.
#
# See build_kythe.sh if you want to actually build Kythe locally, outside of a Docker image build.
#
# See README.md for more details.

set -e


KYTHE_DOCKER_IMAGE_TAG=$1
if [ -z "$KYTHE_DOCKER_IMAGE_TAG" ];
then
  echo "Usage: $0 <kythe_docker_image_tag> (e.g., b3a726a6b03b-000)"
  exit 1
fi

ECR_REPO=283194185447.dkr.ecr.us-east-1.amazonaws.com/kythe
KYTHE_RELEASES="${HOME}/kythe_releases"

echo "Logging in to ECR repo"
`aws --region=us-east-1 ecr get-login --no-include-email`

mkdir -p ${KYTHE_RELEASES}

docker_image="${ECR_REPO}:${KYTHE_DOCKER_IMAGE_TAG}"
echo "Pulling Docker image containing Kythe release: ${docker_image}"
docker pull ${docker_image}

echo "Getting Kythe release out of image"
kythe_release_dir="${KYTHE_RELEASES}/kythe-release"
rm -rf ${kythe_release_dir}
tmp_container_id=$(docker create ${docker_image})
docker cp ${tmp_container_id}:/kythe/kythe-release ${KYTHE_RELEASES}
docker rm -v ${tmp_container_id}

# Get the offical kythe release semver.
kythe_release=`cat ${kythe_release_dir}/RELEASES.md  | grep -o "^\[v.*\]" | head -n 1`
kythe_release=${kythe_release#?}  # Strip leading [
kythe_release=${kythe_release%?}  # Strip trailing ]
echo "Official Kythe release: ${kythe_release}"

# Get the most recent published release.
latest_published_release=`find kythe/java_indexer -type d -name '${kythe_release}-*' -exec basename {} \; | sort | tail -n 1`
if [ -z "$latest_published_release" ]
then
  custom_release_version="001"
else
  custom_release_parts_arr=(${latest_published_release//-/ })
  prev_custom_release_version=`echo ${custom_release_parts_arr[1]} | egrep -o '[0-9]+'`
  custom_release_version=`printf "%03d" $((10#$prev_custom_release_version + 1))`
fi

echo "Latest custom Kythe release within that official release: ${latest_published_release}"

let p=${#KYTHE_DOCKER_IMAGE_TAG}-12
current_kythe_rev=${KYTHE_DOCKER_IMAGE_TAG:p}

echo "Current Kythe rev: ${current_kythe_rev}"

custom_kythe_release="${kythe_release}-toolchain${custom_release_version}-${current_kythe_rev}"
custom_kythe_release_dir="${KYTHE_RELEASES}/kythe-${custom_kythe_release}"
custom_kythe_release_tarball="${custom_kythe_release_dir}.tar.gz"
echo "New custom Kythe release: ${custom_kythe_release}"

# Create the tarball so that its content is a single directory with the unversioned name `kythe-release`,
# so that client code doesn't have to deal with a changing subdir.
echo "Creating Kythe release tarball"
rm -f ${custom_kythe_release_tarball}
GZIP=-9 tar cfz ${custom_kythe_release_tarball} -C ${KYTHE_RELEASES} kythe-release
chmod 755 ${custom_kythe_release_tarball}

# Now rename to a version-specific local loose dir.
rm -rf ${custom_kythe_release_dir}
mv ${kythe_release_dir} ${custom_kythe_release_dir}


echo "Created local custom kythe release at ${custom_kythe_release_tarball}"

echo "Run ./kythe/publish_kythe.sh ${custom_kythe_release} and git push origin master to publish externally."
