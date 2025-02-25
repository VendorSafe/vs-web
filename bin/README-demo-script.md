# Demo Script

This directory contains an automated demo script that demonstrates the complete workflow of the VendorSafe training platform.

## Quick Start

To run the demo script:

```bash
# Option 1: Run directly
node bin/demo-script.js

# Option 2: Run using npm script
npm run demo

# Option 3: Run using yarn
yarn demo
```

## Prerequisites

Before running the demo script, ensure you have the following:

1. Node.js and npm/yarn installed
2. Puppeteer installed (`npm install puppeteer` or `yarn add puppeteer`)
3. A running instance of the VendorSafe application (`bin/dev`)

## What the Demo Shows

The script demonstrates the following workflow:

1. Admin adds a customer
2. Customer creates a training program with video content and quiz
3. Customer invites a vendor
4. Vendor invites an employee
5. Employee completes training and earns a certificate

## Screenshots

The script takes screenshots at key points in the workflow and saves them to the `screenshots` directory.

## Documentation

For more detailed documentation, see [docs/DEMO_SCRIPT.md](../docs/DEMO_SCRIPT.md).