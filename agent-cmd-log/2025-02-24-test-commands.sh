#!/bin/zsh -l
# Script created on 2025-02-24 to test certificate feature fixes

# Set working directory
cd /Volumes/JS-DEV/vs-web

# Install the correct bundler version
echo "Installing bundler 2.5.22..."
gem install bundler:2.5.22

# Run the certificate job test
echo "Running certificate job test..."
bundle exec rails test test/jobs/generate_certificate_pdf_job_test.rb

# Run the certificate system test
echo "Running certificate system test..."
bundle exec rails test test/system/training_certificates_test.rb

# Output completion message
echo "Tests completed!"