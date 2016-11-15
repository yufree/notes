#!/bin/sh

set -e

git config --global user.email "yufree@live.cn"
git config --global user.name "yufree"

git clone -b gh-pages https://${GITHUB_PATH}@github.com/${TRAVIS_REPO_SLUG}.git notes_site
cd notes_site
cp -r ../_book/* ./
git add .
git commit -m "Update the book" || true
git push origin gh-pages
