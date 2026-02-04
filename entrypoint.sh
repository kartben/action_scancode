#!/bin/sh -l

set -eu

git config user.name "Automated Publisher"
git config user.email "publish-to-github-action@users.noreply.github.com"

mkdir -p ${1}

files="$( git diff --name-only --diff-filter=A origin/${GITHUB_BASE_REF}.. )"
for f in $files; do
	echo "found new file: $f";
	cp --parents  $f ${1};
done

mkdir -p $GITHUB_WORKSPACE/artifacts

cd /opt/scancode-toolkit
./scancode \
	-clipeu \
	--license --license-text --license-references \
	--classify \
	--summary \
	--verbose $GITHUB_WORKSPACE/$1 \
	--processes `expr $(nproc --all) - 1` \
	--json $GITHUB_WORKSPACE/artifacts/scancode.json \
	--html $GITHUB_WORKSPACE/artifacts/scancode.html


python /license_check.py -c $GITHUB_WORKSPACE/.github/license_config.yml -s $GITHUB_WORKSPACE/artifacts/scancode.json  -f $GITHUB_WORKSPACE/$1 -o $GITHUB_WORKSPACE/artifacts/report.txt
