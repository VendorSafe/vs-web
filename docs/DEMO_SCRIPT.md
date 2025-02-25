# Demo Script Documentation

This document provides information about the automated demo script for the VendorSafe training platform.

Last updated: February 24, 2025

## Overview

The demo script (`bin/demo-script.js`) is a Puppeteer-based automation script that demonstrates the complete workflow of the VendorSafe training platform. It shows the interactions between different roles (admin, customer, vendor, employee) throughout the lifecycle of a training program.

## Prerequisites

Before running the demo script, ensure you have the following:

1. **Node.js and npm installed**
   ```bash
   node --version  # Should be v14.0.0 or higher
   npm --version   # Should be v6.0.0 or higher
   ```

2. **Puppeteer installed**
   ```bash
   npm install puppeteer
   ```

3. **A running instance of the VendorSafe application**
   ```bash
   bin/dev  # Start the development server
   ```

## Running the Demo

To run the demo script:

```bash
bin/demo-script.js
```

The script will:
1. Launch a browser window
2. Execute the demo workflow
3. Take screenshots at key points
4. Save screenshots to the `screenshots` directory

## Demo Workflow

The script demonstrates the following workflow:

### 1. Admin Adds a Customer
- Admin logs in
- Creates a new customer team
- Adds a customer user to the team
- Assigns the customer role

### 2. Customer Creates a Training Program
- Customer logs in
- Creates a new training program
- Adds video content to the program
- Creates a quiz with questions

### 3. Customer Invites a Vendor
- Customer invites a vendor user
- Vendor registers and accepts the invitation

### 4. Vendor Invites an Employee
- Vendor logs in
- Invites an employee user
- Assigns training to the employee
- Employee registers and accepts the invitation

### 5. Employee Completes Training
- Employee logs in
- Accepts the training invitation
- Completes the video content
- Takes the quiz
- Receives a certificate

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

## Screenshots

The script takes screenshots at key points in the workflow and saves them to the `screenshots` directory. Each screenshot is named with the step and a timestamp.

Example screenshots:
- `admin-dashboard-2025-02-24T12-34-56.png`
- `customer-created-program-2025-02-24T12-35-23.png`
- `vendor-invited-employee-2025-02-24T12-36-45.png`
- `employee-certificate-2025-02-24T12-38-12.png`

## Troubleshooting

If you encounter issues running the demo script:

1. **Timeout errors**
   - Increase the `defaultTimeout` value in the configuration
   - Check if the application is running and accessible

2. **Selector errors**
   - The script may need to be updated if the application's HTML structure has changed
   - Check the console output for specific errors

3. **Authentication issues**
   - Ensure the user credentials in the configuration are correct
   - Check if the authentication flow has changed

4. **Browser launch issues**
   - Try running in headless mode (`headless: true`)
   - Check if Puppeteer is installed correctly

## Customization

The demo script can be customized to demonstrate different workflows:

1. **Different roles**
   - Modify the `users` section in the configuration
   - Update the workflow functions to demonstrate different role interactions

2. **Different training content**
   - Modify the `trainingProgram` section in the configuration
   - Update the `customerCreateTrainingProgram` function to create different content types

3. **Different scenarios**
   - Add new functions for additional scenarios
   - Modify the `runDemo` function to include or exclude specific parts of the workflow

## Integration with Testing

The demo script can be adapted for use in automated testing:

1. **System tests**
   - Add assertions to verify expected behavior
   - Integrate with a testing framework like Jest or Mocha

2. **CI/CD pipeline**
   - Run in headless mode
   - Add reporting for test results
   - Configure to run on specific branches or pull requests

## Maintenance

To keep the demo script up-to-date:

1. **Regular testing**
   - Run the script periodically to ensure it still works
   - Update selectors and workflows as the application evolves

2. **Version control**
   - Keep the script in version control alongside the application
   - Document changes in commit messages

3. **Documentation**
   - Update this documentation when making significant changes
   - Add comments to the script for complex sections