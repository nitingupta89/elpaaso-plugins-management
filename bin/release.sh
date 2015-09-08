#!/usr/bin/env bash
#
# Copyright (C) 2015 Orange
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
if [ "${TRAVIS_PULL_REQUEST}" = "false" -a "$TRAVIS_BRANCH" = "master" ]
then
	RELEASE_CANDIDATE_VERSION=$(cat RELEASE_CANDIDATE_VERSION)
	export REPO_NAME=$(expr ${TRAVIS_REPO_SLUG} : ".*\/\(.*\)")
	export TAG_NAME="releases/$RELEASE_CANDIDATE_VERSION"

	export TAG_DESC="Generated tag from TravisCI for build $TRAVIS_BUILD_NUMBER - $TAG_NAME. [ ![Download](https://api.bintray.com/packages/elpaaso/maven/elpaaso-plugins-management/images/download.svg) ](https://bintray.com/elpaaso/maven/$REPO_NAME/)"
	export RELEASE_NAME=$(expr "$RELEASE_CANDIDATE_VERSION" : "\(.*\)-SNAP.*")
	curl --silent -X POST --data '{"tag_name":"' $TAG_NAME'","target_commitish":"master","name":"'$RELEASE_NAME'","body":"'$TAG_DESC'","draft": true,"prerelease": true}' https://$GH_TAGPERM@api.github.com/repos/Orange-OpenSource/$REPO_NAME/releases
	echo "Extracted Travis repo name: $REPO_NAME"

	JFROG_PROMOTION_URL=http://oss.jfrog.org/api/plugins/build/promote/snapshotsToBintray/$REPO_NAME/${TRAVIS_BUILD_NUMBER}
	echo "Promotion URL to use: $JFROG_PROMOTION_URL"
	curl --silent -X POST -u ${BINTRAY_USER}:${BINTRAY_PASSWORD} $JFROG_PROMOTION_URL

fi