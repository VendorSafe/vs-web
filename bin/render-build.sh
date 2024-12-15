#!/usr/bin/env bash
# Exit on error
set -o errexit

echo "Current Dir: $(pwd)"

# Enable Corepack to manage package managers
corepack enable

# Create .yarn directory if it doesn't exist
mkdir -p .yarn/releases

# Set the Yarn version to 4.2.2 and create the necessary yarnPath file
yarn set version 4.2.2

# Verify that the correct version of Yarn is set
echo "Using Yarn version: $(yarn --version)"

# Install Ruby gems and precompile assets
bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean

# Migrate and seed the database
bundle exec rails db:migrate 
bundle exec rails db:seed
