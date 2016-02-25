#!/usr/bin/env bash

set -euxo pipefail

bundle install --path /var/bundle --jobs $(nproc) --clean

mkdir -p plugin_data
bundle exec ruby -Ilib -e 'require "plugin_updater"; PluginUpdater.update'

bundle exec middleman build

cd build
aws s3 sync assets s3://static.lita.io
aws s3 sync images s3://static.lita.io
aws s3 sync javascripts s3://static.lita.io
aws s3 sync stylesheets s3://static.lita.io

cd docs
aws s3 sync . s3://docs.lita.io --content-type 'text/html; charset=utf-8' --delete

cd ../plugins
aws s3 sync . s3://plugins.lita.io --content-type 'text/html; charset=utf-8' --delete

cd ../www
aws s3 sync . s3://www.lita.io --content-type 'text/html; charset=utf-8' --delete
aws s3api put-object --bucket 'www.lita.io' --key 'plugins/index.html' --metadata 'x-amz-website-redirect-location=https://plugins.lita.io/'

echo 'lita.io deployed!'
