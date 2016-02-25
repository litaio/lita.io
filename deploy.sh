#!/usr/bin/env bash

set -euxo pipefail

bundle install --path /var/bundle --jobs $(nproc) --clean

mkdir -p plugin_data
bundle exec ruby -Ilib -e 'require "plugin_updater"; PluginUpdater.update'

bundle exec middleman build

cd build
aws s3 sync . s3://static.lita.io --delete --exclude '*' --include 'assets/*' --include 'images/*' --include 'javascripts/*' --include 'stylesheets/*'

cd docs
aws s3 sync . s3://docs.lita.io --content-type 'text/html; charset=utf-8' --delete

cd ../plugins
aws s3 sync . s3://plugins.lita.io --content-type 'text/html; charset=utf-8' --delete

cd ../www
aws s3 sync . s3://www.lita.io --content-type 'text/html; charset=utf-8' --delete --exclude 'plugins/*'
aws s3 sync . s3://www.lita.io --exclude '*' --include 'plugins/*' --website-redirect 'https://plugins.lita.io/'

echo 'lita.io deployed!'
