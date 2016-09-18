#!/bin/sh

set -e

[ -z "${GITHUB_PAT}" ] && exit 0
[ "${TRAVIS_BRANCH}" != "master" ] && exit 0

git config --global user.email "yufree@live.cn"
git config --global user.name "yufree"

git clone -b gh-pages https://${GITHUB_PAT}@github.com/${TRAVIS_REPO_SLUG}.git _site
cd _site
git add --all *
git commit -m "Update the notes" || true
git push origin gh-pages
