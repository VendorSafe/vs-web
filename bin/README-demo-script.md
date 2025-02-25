# Demo Script

This directory contains an automated demo script that demonstrates the complete workflow of the VendorSafe training platform.

## Quick Start

To run the demo script:

```bash
# Basic scenario (default)
yarn demo

# Reset database before running
yarn demo -- --reset-db

# Advanced scenario with pre-seeded data
yarn demo -- --scenario=advanced

# Reset database and run advanced scenario
yarn demo -- --reset-db --scenario=advanced
```

## Prerequisites

Before running the demo script, ensure you have the following:

1. Node.js and yarn installed
2. Puppeteer installed (`yarn add puppeteer`)
3. A running instance of the VendorSafe application (`bin/dev`)

## Available Scenarios

### Basic Scenario (Default)

The basic scenario demonstrates the following workflow from scratch:

1. Admin adds a customer
2. Customer creates a training program with video content and quiz
3. Customer invites a vendor
4. Vendor invites an employee
5. Employee completes training and earns a certificate

### Advanced Scenario

The advanced scenario uses pre-seeded data to demonstrate more complex interactions:

1. Admin manages multiple customers
2. Customer manages multiple training programs
3. Customer manages multiple vendors
4. Vendor manages multiple employees
5. Employee completes multiple trainings

## Database Reset

The `--reset-db` option resets the database before running the demo:

- For the basic scenario, it resets to a clean state
- For the advanced scenario, it loads seed data from `db/seeds/advanced.rb`

### Error Handling

The script includes robust error handling for database operations:

- If the database reset fails, you'll be prompted to continue without resetting
- The script attempts multiple approaches to reset the database:
  1. First tries to drop and recreate the database
  2. Then loads the schema
  3. Finally loads the appropriate seeds
- Detailed error messages are provided to help diagnose issues

### Onboarding Process Handling

The script automatically handles the onboarding process that occurs after first login:

- Detects when the onboarding form is displayed
- Automatically enters team name and selects timezone
- Submits the form to complete the onboarding process
- Takes screenshots at key points during onboarding
- Gracefully continues if onboarding is not required

### Enhanced Resilience

The script includes several features to make it more resilient:

- Multiple selector fallbacks for dashboard detection
- Comprehensive error handling for missing UI elements
- Fallback methods for form submission (click or Enter key)
- Graceful continuation when elements can't be found
- Improved seed data handling for duplicate records
- Flexible timeouts with appropriate fallbacks

## Screenshots

The script takes screenshots at key points in the workflow and saves them to the `screenshots` directory.

## Documentation

For more detailed documentation, see [docs/DEMO_SCRIPT.md](../docs/DEMO_SCRIPT.md).