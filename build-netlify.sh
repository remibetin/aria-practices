#!/bin/bash

set -e

if [ -d "wai-aria-practices" ]; then
    echo "wai-aria-practices directory already exists. Removing..."
    rm -rf wai-aria-practices
fi

echo "Cloning wai-aria-practices repository"
git clone --depth 1 --branch main https://github.com/w3c/wai-aria-practices wai-aria-practices
cd wai-aria-practices

echo "Deinitializing aria-practices submodule..."
git submodule deinit -f "_external/aria-practices" || true

if [ -d "_external/aria-practices" ]; then
  echo "Removing stale aria-practices directory..."
  rm -rf "_external/aria-practices"
fi

mkdir _external/aria-practices

# Copy aria-practices files
cd ..
tar --exclude='wai-aria-practices/' --exclude='node_modules/' --exclude='.git/' -cf - . | tar -xf - -C wai-aria-practices/_external/aria-practices
cd wai-aria-practices

# Update site files
bundle install
npm install -C scripts/pre-build
node ./scripts/pre-build

# Build Jekyll site
bundle update wai-website-theme --conservative
bundle update wai-website-plugin --conservative
bundle exec jekyll build --config '_config.yml,_config_staging.yml'
