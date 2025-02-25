# Demo Script Documentation

This document provides information about the automated demo script for the VendorSafe training platform.

Last updated: February 24, 2025

## Overview

The demo script (`bin/demo-script.js`) is a Puppeteer-based automation script that demonstrates the complete workflow of the VendorSafe training platform. It shows the interactions between different roles (admin, customer, vendor, employee) throughout the lifecycle of a training program.

## Prerequisites

Before running the demo script, ensure you have the following:

1. **Node.js and yarn installed**
   ```bash
   node --version  # Should be v14.0.0 or higher
   yarn --version  # Should be v1.22.0 or higher
   ```

2. **Puppeteer installed**
   ```bash
   yarn add puppeteer
   ```

3. **A running instance of the VendorSafe application**
   ```bash
   bin/dev  # Start the development server
   ```

## Running the Demo

### Basic Usage

To run the demo script with default settings:

```bash
yarn demo
```

### Command Line Options

The script supports several command line options:

```bash
# Reset database before running
yarn demo -- --reset-db

# Run advanced scenario
yarn demo -- --scenario=advanced

# Reset database and run advanced scenario
yarn demo -- --reset-db --scenario=advanced
```

### Available Scenarios

#### Basic Scenario (Default)

The basic scenario demonstrates a complete workflow from scratch:

```bash
yarn demo
# or
yarn demo -- --scenario=basic
```

#### Advanced Scenario

The advanced scenario uses pre-seeded data to demonstrate more complex interactions:

```bash
yarn demo -- --scenario=advanced
```

### Database Reset

The `--reset-db` option resets the database before running the demo:

```bash
# Reset database for basic scenario
yarn demo -- --reset-db

# Reset database for advanced scenario (loads seed data)
yarn demo -- --reset-db --scenario=advanced
```

For the advanced scenario, this loads seed data from `db/seeds/advanced.rb`.

#### Error Handling

The script includes robust error handling for database operations:

- If the database reset fails, you'll be prompted to continue without resetting
- The script attempts multiple approaches to reset the database:
  1. First tries to drop and recreate the database
  2. Then loads the schema
  3. Finally loads the appropriate seeds
- Detailed error messages are provided to help diagnose issues

If you encounter database reset errors, you can:

1. Continue without resetting (answer 'y' when prompted)
2. Exit the script (answer 'n' when prompted)
3. Fix the underlying issue and try again

Common issues that might cause database reset failures:

- Missing database user permissions
- Running database migrations that conflict with the schema
- Issues with the TrainingProgram model's workflow state
- Locked database files

#### Onboarding Process Handling

The script automatically handles the onboarding process that occurs after first login:

- Detects when the onboarding form is displayed after login
- Automatically enters team name and selects timezone
- Submits the form to complete the onboarding process
- Takes screenshots at key points during onboarding
- Gracefully continues if onboarding is not required

This makes the script more resilient to different application states:

- Fresh installations where users need to create their first team
- Existing installations where users are already set up
- Different user roles with varying onboarding requirements

The onboarding process is handled for all user roles (admin, customer, vendor, employee) in both basic and advanced scenarios.

#### Enhanced Resilience Features

The script includes several features to make it more resilient to different UI states and application configurations:

1. **Multiple Selector Fallbacks**:
   - Uses `Promise.race` to try multiple selectors simultaneously
   - Falls back to generic selectors if specific ones aren't found
   - Continues execution even when ideal selectors aren't present

2. **Comprehensive Error Handling**:
   - Catches and logs errors without stopping execution
   - Takes screenshots at error points for debugging
   - Provides detailed error messages in the console

3. **Flexible Form Submission**:
   - Tries multiple submit button selectors
   - Falls back to pressing Enter key if no button is found
   - Waits for navigation with appropriate timeouts

4. **Improved Seed Data Handling**:
   - Handles duplicate user records gracefully
   - Uses find-or-create pattern with proper error handling
   - Continues with existing records when duplicates are found

5. **Adaptive Navigation**:
   - Shorter timeouts for individual elements (10s instead of 30s)
   - Multiple fallback strategies for page navigation
   - Screenshot capture at key decision points

These resilience features make the script much more robust when running in different environments, with different data states, and with variations in the UI structure.

## Demo Workflows

### Basic Scenario

The basic scenario demonstrates the following workflow:

#### 1. Admin Adds a Customer
- Admin logs in
- Creates a new customer team
- Adds a customer user to the team
- Assigns the customer role

#### 2. Customer Creates a Training Program
- Customer logs in
- Creates a new training program
- Adds video content to the program
- Creates a quiz with questions

#### 3. Customer Invites a Vendor
- Customer invites a vendor user
- Vendor registers and accepts the invitation

#### 4. Vendor Invites an Employee
- Vendor logs in
- Invites an employee user
- Assigns training to the employee
- Employee registers and accepts the invitation

#### 5. Employee Completes Training
- Employee logs in
- Accepts the training invitation
- Completes the video content
- Takes the quiz
- Receives a certificate

### Advanced Scenario

The advanced scenario demonstrates more complex interactions:

#### 1. Admin Manages Multiple Customers
- Admin logs in
- Views customer details
- Checks team members
- Reviews team activity

#### 2. Customer Manages Multiple Training Programs
- Customer logs in
- Views multiple training programs
- Checks program analytics
- Reviews certificates

#### 3. Customer Manages Multiple Vendors
- Customer views vendor list
- Checks vendor details
- Reviews vendor activity

#### 4. Vendor Manages Multiple Employees
- Vendor logs in
- Views employee list
- Checks employee details
- Reviews employee training progress
- Views employee certificates

#### 5. Employee Completes Multiple Trainings
- Employee logs in
- Views assigned training programs
- Completes multiple trainings
- Views earned certificates

## Screenshots

The script takes screenshots at key points in the workflow and saves them to the `screenshots` directory. Each screenshot is named with the step and a timestamp.

Example screenshots:
- `admin-dashboard-2025-02-24T12-34-56.png`
- `customer-created-program-2025-02-24T12-35-23.png`
- `vendor-invited-employee-2025-02-24T12-36-45.png`
- `employee-certificate-2025-02-24T12-38-12.png`

## Configuration

The script includes a configuration section at the top that can be modified:

```javascript
const config = {
  baseUrl: 'http://localhost:3000',
  headless: false,  // Set to true for headless mode
  slowMo: 50,       // Slow down operations for visibility
  viewportWidth: 1280,
  viewportHeight: 800,
  defaultTimeout: 30000,
  users: {
    // User credentials and information
  },
  trainingProgram: {
    // Training program details
  }
};
```

Key configuration options:
- `baseUrl`: The URL of the VendorSafe application
- `headless`: Whether to run the browser in headless mode
- `slowMo`: Delay between operations (in milliseconds)
- `users`: Credentials and information for demo users
- `trainingProgram`: Details of the training program to create

## Database Reset Functionality

The script includes functionality to reset the database before running the demo:

```javascript
// Reset database if requested
if (shouldResetDb) {
  const resetSuccess = helpers.resetDatabase();
  if (!resetSuccess) {
    helpers.log('Failed to reset database. Exiting demo.');
    process.exit(1);
  }
}
```

For the advanced scenario, it also runs scenario-specific seeds:

```javascript
// Run scenario-specific seeds
if (scenario === 'advanced') {
  helpers.log('Running advanced scenario seeds...');
  execSync('bin/rails db:seed:advanced', { stdio: 'inherit' });
  helpers.log('Advanced scenario seeds complete');
}
```

The seed data for the advanced scenario is defined in `db/seeds/advanced.rb`.

## Troubleshooting

If you encounter issues running the demo script:

1. **Timeout errors**
   - Increase the `defaultTimeout` value in the configuration
   - Check if the application is running and accessible
   - Try running with a higher `slowMo` value

2. **Selector errors**
   - The script may need to be updated if the application's HTML structure has changed
   - Check the console output for specific errors
   - Update the selectors in the script to match the current HTML structure

3. **Authentication issues**
   - Ensure the user credentials in the configuration are correct
   - Check if the authentication flow has changed
   - Verify that the users exist in the database

4. **Browser launch issues**
   - Try running in headless mode (`headless: true`)
   - Check if Puppeteer is installed correctly
   - Update Puppeteer to the latest version

5. **Database reset issues**
   - Ensure you have permission to reset the database
   - Check if the Rails environment is properly configured
   - Verify that the seed files exist and are valid

## Customization

The demo script can be customized to demonstrate different workflows:

1. **Different roles**
   - Modify the `users` section in the configuration
   - Update the workflow functions to demonstrate different role interactions
   - Add new role-specific functions as needed

2. **Different training content**
   - Modify the `trainingProgram` section in the configuration
   - Update the `customerCreateTrainingProgram` function to create different content types
   - Add new content types and interactions

3. **New scenarios**
   - Create a new scenario by adding a case to the scenario switch statement
   - Implement scenario-specific functions
   - Create a corresponding seed file in `db/seeds/`

4. **Custom configuration**
   - Add new configuration options to the `config` object
   - Use environment variables for sensitive information
   - Create configuration profiles for different environments

## Integration with Testing

The demo script can be adapted for use in automated testing:

1. **System tests**
   - Add assertions to verify expected behavior
   - Integrate with a testing framework like Jest or Mocha
   - Use the script as a basis for end-to-end tests

2. **CI/CD pipeline**
   - Run in headless mode
   - Add reporting for test results
   - Configure to run on specific branches or pull requests

3. **Regression testing**
   - Use the script to verify core functionality after updates
   - Compare screenshots to detect UI changes
   - Add specific tests for critical workflows

## Maintenance

To keep the demo script up-to-date:

1. **Regular testing**
   - Run the script periodically to ensure it still works
   - Update selectors and workflows as the application evolves
   - Add new features as they are implemented

2. **Version control**
   - Keep the script in version control alongside the application
   - Document changes in commit messages
   - Tag versions that correspond to application releases

3. **Documentation**
   - Update this documentation when making significant changes
   - Add comments to the script for complex sections
   - Keep the README in the bin directory up to date