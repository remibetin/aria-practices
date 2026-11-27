#!/bin/bash

set -e

if [ -d "wai-aria-practices" ]; then
    echo "wai-aria-practices directory already exists. Removing..."
    rm -rf wai-aria-practices
fi

echo "Cloning wai-aria-practices repository"
git clone --depth 1 --branch main https://github.com/w3c/wai-aria-practices wai-aria-practices

if [ -d "_external/aria-practices" ]; then
  echo "Removing aria-practices submodule directory..."
  rm -rf wai-aria-practices/_external/aria-practices
fi

mkdir wai-aria-practices/_external/aria-practices

# Copy aria-practices files
echo "Copying aria-practices files into the submodule directory..."
touch archive.tar.gz
tar --exclude='wai-aria-practices' --exclude='.git' --exclude='archive.tar.gz' -cf - . | tar -xf - -C wai-aria-practices/_external/aria-practices
rm archive.tar.gz

# Update site files
echo "Updating site files..."
cd wai-aria-practices
bundle install
npm install -C scripts/pre-build
node ./scripts/pre-build

# Build Jekyll site
echo "Building Jekyll site..."
bundle update wai-website-theme --conservative
bundle update wai-website-plugin --conservative
bundle exec jekyll build --config '_config.yml,_config_staging.yml'
