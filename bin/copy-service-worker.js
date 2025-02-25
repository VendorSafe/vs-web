#!/usr/bin/env node

/**
 * This script copies the service worker file from the app/javascript directory
 * to the public directory so it can be served from the root path.
 */

const fs = require('fs');
const path = require('path');

// Define paths
const sourceFile = path.resolve(__dirname, '../app/javascript/training-program-viewer/service-worker.js');
const destFile = path.resolve(__dirname, '../public/service-worker.js');

// Ensure the source file exists
if (!fs.existsSync(sourceFile)) {
  console.error('Error: Service worker source file not found:', sourceFile);
  process.exit(1);
}

// Copy the file
try {
  // Read the source file
  const content = fs.readFileSync(sourceFile, 'utf8');
  
  // Write to the destination
  fs.writeFileSync(destFile, content, 'utf8');
  
  console.log('Service worker successfully copied to:', destFile);
  process.exit(0);
} catch (error) {
  console.error('Error copying service worker:', error);
  process.exit(1);
}