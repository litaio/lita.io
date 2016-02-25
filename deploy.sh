#!/usr/bin/env bash

set -euxo pipefail

gem install bundler

bundle install --path /var/bundle --jobs $(nproc) --clean

bundle exec ruby -Ilib -rplugin_updater -e 'PluginUpdater.update'

bundle exec middleman build

cd build
aws s3 sync assets s3://static.lita.io
aws s3 sync images s3://static.lita.io
aws s3 sync javascripts s3://static.lita.io
aws s3 sync stylesheets s3://static.lita.io

cd docs
aws s3 sync . s3://docs.lita.io

cd ../plugins
aws s3 sync . s3://plugins.lita.io

cd ../www
aws s3 sync . s3://www.lita.io

echo 'lita.io deployed!'
