#!/usr/bin/env node

/**
 * VendorSafe Training Platform Demo Script
 *
 * This script demonstrates the complete workflow of the VendorSafe training platform,
 * showing interactions between different roles (admin, customer, vendor, employee)
 * throughout the lifecycle of a training program.
 *
 * Usage:
 * yarn demo [--reset-db] [--scenario=basic|advanced]
 *
 * Options:
 * --reset-db         Reset the database before running the demo
 * --scenario=basic   Run the basic scenario (default)
 * --scenario=advanced Run the advanced scenario with more features
 *
 * Requirements:
 * - yarn add puppeteer
 * - A running instance of the VendorSafe application
 */

const puppeteer = require('puppeteer');
const { execSync } = require('child_process');
const fs = require('fs');

// Parse command line arguments
const args = process.argv.slice(2);
const shouldResetDb = args.includes('--reset-db');
const scenarioArg = args.find(arg => arg.startsWith('--scenario='));
const scenario = scenarioArg ? scenarioArg.split('=')[1] : 'basic';

// Configuration
const config = {
  baseUrl: 'http://localhost:3000',
  headless: false, // Set to true for headless mode
  slowMo: 50, // Slow down operations by 50ms for visibility
  viewportWidth: 1280,
  viewportHeight: 800,
  defaultTimeout: 30000, // 30 seconds
  users: {
    admin: {
      email: 'admin@vendorsafe.com',
      password: 'password123',
      name: 'Admin User',
      company: 'VendorSafe Admin'
    },
    customer: {
      email: 'customer@example.com',
      password: 'password123',
      name: 'Customer User',
      company: 'Example Power Plant'
    },
    vendor: {
      email: 'vendor@cemstech.com',
      password: 'password123',
      name: 'Vendor User',
      company: 'CEMS Technology Inc.'
    },
    employee: {
      email: 'employee@cemstech.com',
      password: 'password123',
      name: 'Employee User',
      company: 'CEMS Technology Inc.'
    }
  },
  trainingProgram: {
    title: 'CEMS Certification Program',
    description: 'Comprehensive training for Continuous Emissions Monitoring Systems (CEMS)',
    price: '199.99',
    videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // Example video URL
    duration: '2 hours'
  }
};

// Helper functions
const helpers = {
  /**
   * Wait for a specified amount of time
   * @param {number} ms - Time to wait in milliseconds
   */
  sleep: (ms) => new Promise(resolve => setTimeout(resolve, ms)),
  
  /**
   * Log a message with timestamp
   * @param {string} message - Message to log
   */
  log: (message) => {
    const timestamp = new Date().toISOString().replace('T', ' ').substr(0, 19);
    console.log(`[${timestamp}] ${message}`);
  },
  
  /**
   * Take a screenshot
   * @param {Page} page - Puppeteer page object
   * @param {string} name - Screenshot name
   */
  screenshot: async (page, name) => {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    await page.screenshot({
      path: `screenshots/${name}-${timestamp}.png`,
      fullPage: true
    });
    helpers.log(`Screenshot saved: ${name}-${timestamp}.png`);
  },
  
  /**
   * Handle onboarding process after login
   * @param {Page} page - Puppeteer page object
   * @param {string} teamName - Team name to enter during onboarding
   */
  handleOnboarding: async (page, teamName) => {
    try {
      // Wait a moment for any redirects or form loading
      await helpers.sleep(2000);
      
      // Take a screenshot to see what's on the page
      await helpers.screenshot(page, 'post-login-pre-onboarding');
      
      // Check if onboarding form is present with a more comprehensive set of selectors
      const onboardingFormExists = await page.evaluate(() => {
        const selectors = [
          'form.onboarding-form',
          'form#new_team',
          'div.onboarding-container',
          'form[action*="/teams"]',
          'input#team_name',
          'input[name="team[name]"]',
          'h1:contains("Create your team")',
          'h1:contains("Welcome")',
          'h2:contains("Create your team")',
          'h2:contains("Welcome")'
        ];
        
        return selectors.some(selector => {
          try {
            return !!document.querySelector(selector);
          } catch (e) {
            // Some complex selectors might not be supported
            return false;
          }
        });
      });
      
      if (onboardingFormExists) {
        helpers.log('Onboarding form or welcome page detected');
        await helpers.screenshot(page, 'onboarding-form');
        
        // Try to find and fill team name input field
        try {
          // Check if team name input exists
          const teamNameInputExists = await page.evaluate(() => {
            return !!document.querySelector('input#team_name, input[name="team[name]"]');
          });
          
          if (teamNameInputExists) {
            helpers.log('Entering team name: ' + teamName);
            await page.type('input#team_name, input[name="team[name]"]', teamName);
            
            // Try to find and select timezone
            try {
              const timezoneSelectExists = await page.evaluate(() => {
                return !!document.querySelector('select#team_time_zone, select[name="team[time_zone]"]');
              });
              
              if (timezoneSelectExists) {
                helpers.log('Selecting timezone: Pacific Time (US & Canada)');
                await page.select('select#team_time_zone, select[name="team[time_zone]"]', 'Pacific Time (US & Canada)');
              } else {
                helpers.log('No timezone selector found, continuing...');
              }
            } catch (timezoneError) {
              helpers.log(`Warning: Error selecting timezone: ${timezoneError.message}`);
              // Continue anyway
            }
            
            // Try to submit the form
            try {
              // Look for submit button with various selectors
              const submitButtonSelector = 'input[type="submit"], button[type="submit"], button.submit-button, .btn-primary, .button';
              const submitButtonExists = await page.evaluate((selector) => {
                return !!document.querySelector(selector);
              }, submitButtonSelector);
              
              if (submitButtonExists) {
                helpers.log('Submitting onboarding form');
                await page.click(submitButtonSelector);
                
                // Wait for navigation or timeout
                try {
                  await Promise.race([
                    page.waitForNavigation({ timeout: 10000 }),
                    page.waitForSelector('.dashboard-header, .dashboard, .home-header, h1', { timeout: 10000 })
                  ]);
                  helpers.log('Navigation after form submission complete');
                } catch (navError) {
                  helpers.log(`Warning: Navigation timeout after form submission: ${navError.message}`);
                  // Continue anyway
                }
                
                await helpers.screenshot(page, 'onboarding-complete');
                helpers.log('Onboarding form submitted');
              } else {
                helpers.log('Warning: Could not find submit button on onboarding form');
                // Try pressing Enter on the last input field as a fallback
                await page.keyboard.press('Enter');
                helpers.log('Pressed Enter key as fallback for form submission');
                await helpers.sleep(2000);
                await helpers.screenshot(page, 'onboarding-enter-key');
              }
            } catch (submitError) {
              helpers.log(`Warning: Error submitting form: ${submitError.message}`);
              // Continue anyway
            }
          } else {
            helpers.log('Warning: Could not find team name input field');
          }
        } catch (inputError) {
          helpers.log(`Warning: Error filling team name: ${inputError.message}`);
          // Continue anyway
        }
      } else {
        helpers.log('No onboarding form detected, continuing...');
      }
    } catch (error) {
      helpers.log(`Warning: Error during onboarding process: ${error.message}`);
      // Continue anyway, as this is just a warning
    }
  },
  
  /**
   * Reset the database
   */
  resetDatabase: () => {
    try {
      helpers.log('Resetting database...');
      
      // First try to drop and recreate the database
      try {
        execSync('bin/rails db:drop db:create', { stdio: 'inherit' });
        helpers.log('Database dropped and recreated');
      } catch (dropError) {
        helpers.log(`Warning: Could not drop/create database: ${dropError.message}`);
        helpers.log('Attempting to continue with schema load...');
      }
      
      // Load the schema
      try {
        execSync('bin/rails db:schema:load', { stdio: 'inherit' });
        helpers.log('Schema loaded successfully');
      } catch (schemaError) {
        helpers.log(`Error loading schema: ${schemaError.message}`);
        return false;
      }
      
      // Run the seeds
      try {
        execSync('bin/rails db:seed', { stdio: 'inherit' });
        helpers.log('Default seeds loaded successfully');
      } catch (seedError) {
        helpers.log(`Warning: Error loading default seeds: ${seedError.message}`);
        helpers.log('Continuing without default seeds...');
      }
      
      // Run scenario-specific seeds
      if (scenario === 'advanced') {
        helpers.log('Running advanced scenario seeds...');
        try {
          execSync('bin/rails db:seed:advanced', { stdio: 'inherit' });
          helpers.log('Advanced scenario seeds complete');
        } catch (advancedSeedError) {
          helpers.log(`Error loading advanced seeds: ${advancedSeedError.message}`);
          helpers.log('The advanced scenario may not work correctly without these seeds.');
          // Continue anyway, as some features might still work
        }
      }
      
      return true;
    } catch (error) {
      helpers.log(`Error resetting database: ${error.message}`);
      if (error.stderr) {
        helpers.log(`Error details: ${error.stderr.toString()}`);
      }
      return false;
    }
  },
  
  /**
   * Create screenshots directory if it doesn't exist
   */
  createScreenshotsDir: () => {
    if (!fs.existsSync('screenshots')) {
      fs.mkdirSync('screenshots');
      helpers.log('Created screenshots directory');
    }
  }
};

/**
 * Main demo function
 */
async function runDemo() {
  helpers.log(`Starting VendorSafe Training Platform Demo (Scenario: ${scenario})`);
  
  // Reset database if requested
  if (shouldResetDb) {
    const resetSuccess = helpers.resetDatabase();
    if (!resetSuccess) {
      helpers.log('Failed to reset database. Continuing without reset.');
      
      // Ask user if they want to continue
      const readline = require('readline').createInterface({
        input: process.stdin,
        output: process.stdout
      });
      
      readline.question('Do you want to continue without resetting the database? (y/n) ', (answer) => {
        readline.close();
        if (answer.toLowerCase() !== 'y') {
          helpers.log('Exiting demo.');
          process.exit(1);
        } else {
          helpers.log('Continuing with demo...');
        }
      });
    }
  }
  
  // Create screenshots directory
  helpers.createScreenshotsDir();
  
  // Launch browser
  const browser = await puppeteer.launch({
    headless: config.headless,
    slowMo: config.slowMo,
    defaultViewport: {
      width: config.viewportWidth,
      height: config.viewportHeight
    },
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  
  try {
    const page = await browser.newPage();
    page.setDefaultTimeout(config.defaultTimeout);
    
    if (scenario === 'basic') {
      // Basic scenario - full workflow from scratch
      helpers.log('Running basic scenario - full workflow from scratch');
      
      // Part 1: Admin adds a new customer
      await adminAddCustomer(page);
      
      // Part 2: Customer creates a training program
      await customerCreateTrainingProgram(page);
      
      // Part 3: Customer invites vendors
      await customerInviteVendor(page);
      
      // Part 4: Vendor invites employees
      await vendorInviteEmployee(page);
      
      // Part 5: Employee completes training
      await employeeCompleteTraining(page);
    } else if (scenario === 'advanced') {
      // Advanced scenario - uses pre-seeded data with more complex interactions
      helpers.log('Running advanced scenario - pre-seeded data with complex interactions');
      
      // Part 1: Admin manages multiple customers
      await adminManageCustomers(page);
      
      // Part 2: Customer manages multiple training programs
      await customerManagePrograms(page);
      
      // Part 3: Customer manages multiple vendors
      await customerManageVendors(page);
      
      // Part 4: Vendor manages multiple employees
      await vendorManageEmployees(page);
      
      // Part 5: Employee completes multiple trainings
      await employeeCompleteMultipleTrainings(page);
    } else {
      helpers.log(`Unknown scenario: ${scenario}. Exiting demo.`);
      process.exit(1);
    }
    
    helpers.log('Demo completed successfully!');
  } catch (error) {
    helpers.log(`Error: ${error.message}`);
    console.error(error);
  } finally {
    await browser.close();
  }
}

/**
 * Admin logs in and adds a new customer
 * @param {Page} page - Puppeteer page object
 */
async function adminAddCustomer(page) {
  helpers.log('Part 1: Admin adds a new customer');
  
  // Navigate to login page
  await page.goto(`${config.baseUrl}/users/sign_in`);
  helpers.log('Navigated to login page');
  
  // Login as admin
  await page.type('#user_email', config.users.admin.email);
  await page.type('#user_password', config.users.admin.password);
  await page.click('input[type="submit"]');
  helpers.log('Logged in as admin');
  
  // Handle onboarding if needed
  await helpers.handleOnboarding(page, config.users.admin.company || 'Admin Organization');
  
  // Wait for dashboard to load - try multiple possible selectors
  try {
    await Promise.race([
      page.waitForSelector('.dashboard-header', { timeout: 10000 }),
      page.waitForSelector('.dashboard', { timeout: 10000 }),
      page.waitForSelector('.home-header', { timeout: 10000 }),
      page.waitForSelector('h1', { timeout: 10000 })
    ]);
    helpers.log('Admin dashboard or home page loaded');
    await helpers.screenshot(page, 'admin-dashboard');
  } catch (error) {
    helpers.log('Warning: Could not find dashboard header. Taking screenshot anyway.');
    await helpers.screenshot(page, 'admin-post-login');
    // Continue anyway
  }
  
  // Navigate to teams page
  await page.click('a[href="/account/teams"]');
  await page.waitForSelector('.teams-header');
  helpers.log('Teams page loaded');
  
  // Click on "New Team" button
  await page.click('a[href="/account/teams/new"]');
  await page.waitForSelector('form#new_team');
  helpers.log('New team form loaded');
  
  // Fill out new team form
  await page.type('#team_name', config.users.customer.company);
  await page.select('#team_time_zone', 'Pacific Time (US & Canada)');
  await page.click('input[type="submit"]');
  helpers.log(`Created new customer team: ${config.users.customer.company}`);
  
  // Wait for team dashboard
  await page.waitForSelector('.team-dashboard');
  await helpers.screenshot(page, 'admin-created-customer');
  
  // Add a new user to the team
  await page.click('a[href*="/account/teams/"][href*="/memberships/new"]');
  await page.waitForSelector('form#new_membership');
  
  // Fill out new membership form
  await page.type('#membership_user_first_name', config.users.customer.name.split(' ')[0]);
  await page.type('#membership_user_last_name', config.users.customer.name.split(' ')[1] || '');
  await page.type('#membership_user_email', config.users.customer.email);
  
  // Select customer role
  await page.click('input[name="membership[role_ids][]"][value="customer"]');
  
  // Submit form
  await page.click('input[type="submit"]');
  helpers.log(`Added customer user: ${config.users.customer.email}`);
  
  // Wait for confirmation
  await page.waitForSelector('.alert-success');
  await helpers.screenshot(page, 'admin-added-customer-user');
  
  // Logout
  await page.click('a[href="/users/sign_out"]');
  await page.waitForSelector('a[href="/users/sign_in"]');
  helpers.log('Admin logged out');
  
  await helpers.sleep(2000);
}

/**
 * Customer logs in and creates a training program
 * @param {Page} page - Puppeteer page object
 */
async function customerCreateTrainingProgram(page) {
  helpers.log('Part 2: Customer creates a training program');
  
  // Navigate to login page
  await page.goto(`${config.baseUrl}/users/sign_in`);
  
  // Login as customer
  await page.type('#user_email', config.users.customer.email);
  await page.type('#user_password', config.users.customer.password);
  await page.click('input[type="submit"]');
  helpers.log('Logged in as customer');
  
  // Handle onboarding if needed
  await helpers.handleOnboarding(page, config.users.customer.company);
  
  // Wait for dashboard to load - try multiple possible selectors
  try {
    await Promise.race([
      page.waitForSelector('.dashboard-header', { timeout: 10000 }),
      page.waitForSelector('.dashboard', { timeout: 10000 }),
      page.waitForSelector('.home-header', { timeout: 10000 }),
      page.waitForSelector('h1', { timeout: 10000 })
    ]);
    helpers.log('Customer dashboard or home page loaded');
    await helpers.screenshot(page, 'customer-dashboard');
  } catch (error) {
    helpers.log('Warning: Could not find dashboard header. Taking screenshot anyway.');
    await helpers.screenshot(page, 'customer-post-login');
    // Continue anyway
  }
  
  // Navigate to training programs page
  await page.click('a[href*="/account/teams/"][href*="/training_programs"]');
  await page.waitForSelector('.training-programs-header');
  helpers.log('Training programs page loaded');
  
  // Click on "New Training Program" button
  await page.click('a[href*="/account/teams/"][href*="/training_programs/new"]');
  await page.waitForSelector('form#new_training_program');
  helpers.log('New training program form loaded');
  
  // Fill out new training program form
  await page.type('#training_program_title', config.trainingProgram.title);
  await page.type('#training_program_description', config.trainingProgram.description);
  await page.type('#training_program_price', config.trainingProgram.price);
  
  // Set program to published state
  await page.select('#training_program_state', 'published');
  
  // Submit form
  await page.click('input[type="submit"]');
  helpers.log(`Created new training program: ${config.trainingProgram.title}`);
  
  // Wait for confirmation
  await page.waitForSelector('.alert-success');
  await helpers.screenshot(page, 'customer-created-program');
  
  // Add video content to the training program
  await page.click('a[href*="/training_contents/new"]');
  await page.waitForSelector('form#new_training_content');
  
  // Fill out new content form
  await page.type('#training_content_title', 'Introduction to CEMS');
  await page.type('#training_content_description', 'Overview of Continuous Emissions Monitoring Systems');
  await page.select('#training_content_content_type', 'video');
  await page.type('#training_content_content_data_video_url', config.trainingProgram.videoUrl);
  await page.type('#training_content_duration', config.trainingProgram.duration);
  
  // Submit form
  await page.click('input[type="submit"]');
  helpers.log('Added video content to training program');
  
  // Wait for confirmation
  await page.waitForSelector('.alert-success');
  await helpers.screenshot(page, 'customer-added-content');
  
  // Add a quiz to the training program
  await page.click('a[href*="/training_contents/new"]');
  await page.waitForSelector('form#new_training_content');
  
  // Fill out new content form for quiz
  await page.type('#training_content_title', 'CEMS Knowledge Check');
  await page.type('#training_content_description', 'Test your knowledge of CEMS');
  await page.select('#training_content_content_type', 'quiz');
  
  // Submit form
  await page.click('input[type="submit"]');
  helpers.log('Added quiz to training program');
  
  // Wait for confirmation
  await page.waitForSelector('.alert-success');
  await helpers.screenshot(page, 'customer-added-quiz');
  
  // Add a question to the quiz
  await page.click('a[href*="/training_questions/new"]');
  await page.waitForSelector('form#new_training_question');
  
  // Fill out new question form
  await page.type('#training_question_question_text', 'What does CEMS stand for?');
  await page.type('#training_question_answer_options_0', 'Continuous Emissions Monitoring System');
  await page.type('#training_question_answer_options_1', 'Complete Environmental Management System');
  await page.type('#training_question_answer_options_2', 'Certified Emissions Measurement Standard');
  await page.type('#training_question_answer_options_3', 'Corporate Environmental Monitoring Service');
  await page.click('#training_question_correct_answer_0'); // Select first option as correct
  
  // Submit form
  await page.click('input[type="submit"]');
  helpers.log('Added question to quiz');
  
  // Wait for confirmation
  await page.waitForSelector('.alert-success');
  await helpers.screenshot(page, 'customer-added-question');
  
  await helpers.sleep(2000);
}

/**
 * Customer invites a vendor
 * @param {Page} page - Puppeteer page object
 */
async function customerInviteVendor(page) {
  helpers.log('Part 3: Customer invites a vendor');
  
  // Navigate to team members page
  await page.click('a[href*="/account/teams/"][href*="/memberships"]');
  await page.waitForSelector('.memberships-header');
  helpers.log('Team members page loaded');
  
  // Click on "Invite Member" button
  await page.click('a[href*="/account/teams/"][href*="/memberships/new"]');
  await page.waitForSelector('form#new_membership');
  
  // Fill out invitation form
  await page.type('#membership_user_first_name', config.users.vendor.name.split(' ')[0]);
  await page.type('#membership_user_last_name', config.users.vendor.name.split(' ')[1] || '');
  await page.type('#membership_user_email', config.users.vendor.email);
  
  // Select vendor role
  await page.click('input[name="membership[role_ids][]"][value="vendor"]');
  
  // Submit form
  await page.click('input[type="submit"]');
  helpers.log(`Invited vendor: ${config.users.vendor.email}`);
  
  // Wait for confirmation
  await page.waitForSelector('.alert-success');
  await helpers.screenshot(page, 'customer-invited-vendor');
  
  // Logout
  await page.click('a[href="/users/sign_out"]');
  await page.waitForSelector('a[href="/users/sign_in"]');
  helpers.log('Customer logged out');
  
  await helpers.sleep(2000);
  
  // Accept vendor invitation
  await page.goto(`${config.baseUrl}/users/sign_up`);
  await page.waitForSelector('form#new_user');
  
  // Fill out registration form
  await page.type('#user_email', config.users.vendor.email);
  await page.type('#user_password', config.users.vendor.password);
  await page.type('#user_password_confirmation', config.users.vendor.password);
  await page.type('#user_first_name', config.users.vendor.name.split(' ')[0]);
  await page.type('#user_last_name', config.users.vendor.name.split(' ')[1] || '');
  
  // Submit form
  await page.click('input[type="submit"]');
  helpers.log('Vendor registration completed');
  
  // Handle onboarding if needed
  await helpers.handleOnboarding(page, config.users.vendor.company);
  
  // Wait for dashboard to load - try multiple possible selectors
  try {
    await Promise.race([
      page.waitForSelector('.dashboard-header', { timeout: 10000 }),
      page.waitForSelector('.dashboard', { timeout: 10000 }),
      page.waitForSelector('.home-header', { timeout: 10000 }),
      page.waitForSelector('h1', { timeout: 10000 })
    ]);
    helpers.log('Vendor dashboard or home page loaded');
    await helpers.screenshot(page, 'vendor-registered');
  } catch (error) {
    helpers.log('Warning: Could not find dashboard header. Taking screenshot anyway.');
    await helpers.screenshot(page, 'vendor-post-registration');
    // Continue anyway
  }
  
  await helpers.sleep(2000);
}

/**
 * Vendor invites an employee
 * @param {Page} page - Puppeteer page object
 */
async function vendorInviteEmployee(page) {
  helpers.log('Part 4: Vendor invites an employee');
  
  // Navigate to team members page
  await page.click('a[href*="/account/teams/"][href*="/memberships"]');
  await page.waitForSelector('.memberships-header');
  helpers.log('Team members page loaded');
  
  // Click on "Invite Member" button
  await page.click('a[href*="/account/teams/"][href*="/memberships/new"]');
  await page.waitForSelector('form#new_membership');
  
  // Fill out invitation form
  await page.type('#membership_user_first_name', config.users.employee.name.split(' ')[0]);
  await page.type('#membership_user_last_name', config.users.employee.name.split(' ')[1] || '');
  await page.type('#membership_user_email', config.users.employee.email);
  
  // Select employee role
  await page.click('input[name="membership[role_ids][]"][value="employee"]');
  
  // Submit form
  await page.click('input[type="submit"]');
  helpers.log(`Invited employee: ${config.users.employee.email}`);
  
  // Wait for confirmation
  await page.waitForSelector('.alert-success');
  await helpers.screenshot(page, 'vendor-invited-employee');
  
  // Navigate to training programs
  await page.click('a[href*="/account/teams/"][href*="/training_programs"]');
  await page.waitForSelector('.training-programs-header');
  helpers.log('Training programs page loaded');
  
  // View the training program
  await page.click('a[href*="/training_programs/"][href*="/show"]');
  await page.waitForSelector('.training-program-details');
  helpers.log('Training program details loaded');
  await helpers.screenshot(page, 'vendor-views-program');
  
  // Assign training to employee
  await page.click('a[href*="/training_invitations/new"]');
  await page.waitForSelector('form#new_training_invitation');
  
  // Select employee
  await page.select('#training_invitation_user_id', config.users.employee.email);
  
  // Set deadline
  const deadline = new Date();
  deadline.setDate(deadline.getDate() + 14); // 2 weeks from now
  const deadlineStr = deadline.toISOString().split('T')[0]; // YYYY-MM-DD
  await page.type('#training_invitation_deadline', deadlineStr);
  
  // Submit form
  await page.click('input[type="submit"]');
  helpers.log(`Assigned training to employee: ${config.users.employee.email}`);
  
  // Wait for confirmation
  await page.waitForSelector('.alert-success');
  await helpers.screenshot(page, 'vendor-assigned-training');
  
  // Logout
  await page.click('a[href="/users/sign_out"]');
  await page.waitForSelector('a[href="/users/sign_in"]');
  helpers.log('Vendor logged out');
  
  await helpers.sleep(2000);
  
  // Accept employee invitation
  await page.goto(`${config.baseUrl}/users/sign_up`);
  await page.waitForSelector('form#new_user');
  
  // Fill out registration form
  await page.type('#user_email', config.users.employee.email);
  await page.type('#user_password', config.users.employee.password);
  await page.type('#user_password_confirmation', config.users.employee.password);
  await page.type('#user_first_name', config.users.employee.name.split(' ')[0]);
  await page.type('#user_last_name', config.users.employee.name.split(' ')[1] || '');
  
  // Submit form
  await page.click('input[type="submit"]');
  helpers.log('Employee registration completed');
  
  // Handle onboarding if needed
  await helpers.handleOnboarding(page, config.users.employee.company || 'Employee Organization');
  
  // Wait for dashboard to load - try multiple possible selectors
  try {
    await Promise.race([
      page.waitForSelector('.dashboard-header', { timeout: 10000 }),
      page.waitForSelector('.dashboard', { timeout: 10000 }),
      page.waitForSelector('.home-header', { timeout: 10000 }),
      page.waitForSelector('h1', { timeout: 10000 })
    ]);
    helpers.log('Employee dashboard or home page loaded');
    await helpers.screenshot(page, 'employee-registered');
  } catch (error) {
    helpers.log('Warning: Could not find dashboard header. Taking screenshot anyway.');
    await helpers.screenshot(page, 'employee-post-registration');
    // Continue anyway
  }
  
  await helpers.sleep(2000);
}

/**
 * Employee completes training
 * @param {Page} page - Puppeteer page object
 */
async function employeeCompleteTraining(page) {
  helpers.log('Part 5: Employee completes training');
  
  // Navigate to training invitations
  await page.click('a[href*="/account/teams/"][href*="/training_invitations"]');
  await page.waitForSelector('.training-invitations-header');
  helpers.log('Training invitations page loaded');
  await helpers.screenshot(page, 'employee-invitations');
  
  // Accept training invitation
  await page.click('a[href*="/accept"]');
  await page.waitForSelector('.alert-success');
  helpers.log('Training invitation accepted');
  await helpers.screenshot(page, 'employee-accepted-invitation');
  
  // Navigate to training programs
  await page.click('a[href*="/account/teams/"][href*="/training_programs"]');
  await page.waitForSelector('.training-programs-header');
  helpers.log('Training programs page loaded');
  
  // Start the training program
  await page.click('a[href*="/training_programs/"][href*="/show"]');
  await page.waitForSelector('.training-program-details');
  helpers.log('Training program details loaded');
  
  // Start the training
  await page.click('a[href*="/start"]');
  await page.waitForSelector('.training-player');
  helpers.log('Training player loaded');
  await helpers.screenshot(page, 'employee-started-training');
  
  // Watch the video content
  await page.click('.video-player-play-button');
  helpers.log('Started watching video content');
  
  // Simulate video completion
  await helpers.sleep(5000); // Wait 5 seconds to simulate watching
  
  // Mark video as completed
  await page.click('.mark-complete-button');
  await page.waitForSelector('.completion-confirmation');
  helpers.log('Video content marked as completed');
  await helpers.screenshot(page, 'employee-completed-video');
  
  // Navigate to the quiz
  await page.click('.next-content-button');
  await page.waitForSelector('.quiz-container');
  helpers.log('Quiz loaded');
  await helpers.screenshot(page, 'employee-quiz');
  
  // Answer the quiz question
  await page.click('.answer-option:first-child'); // Select first option
  await page.click('.submit-answer-button');
  await page.waitForSelector('.answer-feedback');
  helpers.log('Quiz question answered');
  await helpers.screenshot(page, 'employee-answered-quiz');
  
  // Complete the quiz
  await page.click('.complete-quiz-button');
  await page.waitForSelector('.quiz-completion-confirmation');
  helpers.log('Quiz completed');
  await helpers.screenshot(page, 'employee-completed-quiz');
  
  // Generate certificate
  await page.click('.generate-certificate-button');
  await page.waitForSelector('.certificate-container');
  helpers.log('Certificate generated');
  await helpers.screenshot(page, 'employee-certificate');
  
  // Download certificate
  await page.click('.download-certificate-button');
  helpers.log('Certificate downloaded');
  
  // View certificate details
  await page.click('.view-certificate-details-button');
  await page.waitForSelector('.certificate-details');
  helpers.log('Certificate details viewed');
  await helpers.screenshot(page, 'employee-certificate-details');
  
  // Logout
  await page.click('a[href="/users/sign_out"]');
  await page.waitForSelector('a[href="/users/sign_in"]');
  helpers.log('Employee logged out');
  
  await helpers.sleep(2000);
}

/**
 * Advanced scenario functions
 */

/**
 * Admin manages multiple customers
 * @param {Page} page - Puppeteer page object
 */
async function adminManageCustomers(page) {
  helpers.log('Part 1: Admin manages multiple customers');
  
  // Navigate to login page
  await page.goto(`${config.baseUrl}/users/sign_in`);
  helpers.log('Navigated to login page');
  
  // Login as admin
  await page.type('#user_email', config.users.admin.email);
  await page.type('#user_password', config.users.admin.password);
  await page.click('input[type="submit"]');
  helpers.log('Logged in as admin');
  
  // Handle onboarding if needed
  await helpers.handleOnboarding(page, config.users.admin.company);
  
  // Wait for dashboard to load - try multiple possible selectors
  try {
    await Promise.race([
      page.waitForSelector('.dashboard-header', { timeout: 10000 }),
      page.waitForSelector('.dashboard', { timeout: 10000 }),
      page.waitForSelector('.home-header', { timeout: 10000 }),
      page.waitForSelector('h1', { timeout: 10000 })
    ]);
    helpers.log('Admin dashboard or home page loaded');
    await helpers.screenshot(page, 'admin-dashboard-advanced');
  } catch (error) {
    helpers.log('Warning: Could not find dashboard header. Taking screenshot anyway.');
    await helpers.screenshot(page, 'admin-post-login');
    // Continue anyway
  }
  
  // Navigate to teams page
  await page.click('a[href="/account/teams"]');
  await page.waitForSelector('.teams-header');
  helpers.log('Teams page loaded');
  
  // View customer details
  await page.click('a[href*="/account/teams/"][href*="/show"]');
  await page.waitForSelector('.team-details');
  helpers.log('Team details loaded');
  await helpers.screenshot(page, 'admin-team-details');
  
  // View team members
  await page.click('a[href*="/account/teams/"][href*="/memberships"]');
  await page.waitForSelector('.memberships-header');
  helpers.log('Team members loaded');
  await helpers.screenshot(page, 'admin-team-members');
  
  // View team activity
  await page.click('a[href*="/account/teams/"][href*="/activities"]');
  await page.waitForSelector('.activities-header');
  helpers.log('Team activities loaded');
  await helpers.screenshot(page, 'admin-team-activities');
  
  // Logout
  await page.click('a[href="/users/sign_out"]');
  await page.waitForSelector('a[href="/users/sign_in"]');
  helpers.log('Admin logged out');
  
  await helpers.sleep(2000);
}

/**
 * Customer manages multiple training programs
 * @param {Page} page - Puppeteer page object
 */
async function customerManagePrograms(page) {
  helpers.log('Part 2: Customer manages multiple training programs');
  
  // Navigate to login page
  await page.goto(`${config.baseUrl}/users/sign_in`);
  
  // Login as customer
  await page.type('#user_email', config.users.customer.email);
  await page.type('#user_password', config.users.customer.password);
  await page.click('input[type="submit"]');
  helpers.log('Logged in as customer');
  
  // Handle onboarding if needed
  await helpers.handleOnboarding(page, config.users.customer.company);
  
  // Wait for dashboard to load - try multiple possible selectors
  try {
    await Promise.race([
      page.waitForSelector('.dashboard-header', { timeout: 10000 }),
      page.waitForSelector('.dashboard', { timeout: 10000 }),
      page.waitForSelector('.home-header', { timeout: 10000 }),
      page.waitForSelector('h1', { timeout: 10000 })
    ]);
    helpers.log('Customer dashboard or home page loaded');
    await helpers.screenshot(page, 'customer-dashboard-advanced');
  } catch (error) {
    helpers.log('Warning: Could not find dashboard header. Taking screenshot anyway.');
    await helpers.screenshot(page, 'customer-post-login');
    // Continue anyway
  }
  
  // Navigate to training programs page
  await page.click('a[href*="/account/teams/"][href*="/training_programs"]');
  await page.waitForSelector('.training-programs-header');
  helpers.log('Training programs page loaded');
  await helpers.screenshot(page, 'customer-training-programs');
  
  // View program details
  await page.click('a[href*="/training_programs/"][href*="/show"]');
  await page.waitForSelector('.training-program-details');
  helpers.log('Training program details loaded');
  await helpers.screenshot(page, 'customer-program-details');
  
  // View program analytics
  await page.click('a[href*="/analytics"]');
  await page.waitForSelector('.analytics-dashboard');
  helpers.log('Program analytics loaded');
  await helpers.screenshot(page, 'customer-program-analytics');
  
  // View certificates
  await page.click('a[href*="/training_certificates"]');
  await page.waitForSelector('.certificates-list');
  helpers.log('Certificates list loaded');
  await helpers.screenshot(page, 'customer-certificates');
  
  await helpers.sleep(2000);
}

/**
 * Customer manages multiple vendors
 * @param {Page} page - Puppeteer page object
 */
async function customerManageVendors(page) {
  helpers.log('Part 3: Customer manages multiple vendors');
  
  // Navigate to team members page
  await page.click('a[href*="/account/teams/"][href*="/memberships"]');
  await page.waitForSelector('.memberships-header');
  helpers.log('Team members page loaded');
  await helpers.screenshot(page, 'customer-team-members');
  
  // Filter by vendor role
  await page.click('#role-filter-vendor');
  await page.waitForSelector('.vendor-list');
  helpers.log('Vendor list loaded');
  await helpers.screenshot(page, 'customer-vendor-list');
  
  // View vendor details
  await page.click('a[href*="/memberships/"][href*="/show"]');
  await page.waitForSelector('.membership-details');
  helpers.log('Vendor details loaded');
  await helpers.screenshot(page, 'customer-vendor-details');
  
  // View vendor activity
  await page.click('a[href*="/activities"]');
  await page.waitForSelector('.activities-list');
  helpers.log('Vendor activities loaded');
  await helpers.screenshot(page, 'customer-vendor-activities');
  
  // Logout
  await page.click('a[href="/users/sign_out"]');
  await page.waitForSelector('a[href="/users/sign_in"]');
  helpers.log('Customer logged out');
  
  await helpers.sleep(2000);
}

/**
 * Vendor manages multiple employees
 * @param {Page} page - Puppeteer page object
 */
async function vendorManageEmployees(page) {
  helpers.log('Part 4: Vendor manages multiple employees');
  
  // Navigate to login page
  await page.goto(`${config.baseUrl}/users/sign_in`);
  
  // Login as vendor
  await page.type('#user_email', config.users.vendor.email);
  await page.type('#user_password', config.users.vendor.password);
  await page.click('input[type="submit"]');
  helpers.log('Logged in as vendor');
  
  // Handle onboarding if needed
  await helpers.handleOnboarding(page, config.users.vendor.company);
  
  // Wait for dashboard to load - try multiple possible selectors
  try {
    await Promise.race([
      page.waitForSelector('.dashboard-header', { timeout: 10000 }),
      page.waitForSelector('.dashboard', { timeout: 10000 }),
      page.waitForSelector('.home-header', { timeout: 10000 }),
      page.waitForSelector('h1', { timeout: 10000 })
    ]);
    helpers.log('Vendor dashboard or home page loaded');
    await helpers.screenshot(page, 'vendor-dashboard-advanced');
  } catch (error) {
    helpers.log('Warning: Could not find dashboard header. Taking screenshot anyway.');
    await helpers.screenshot(page, 'vendor-post-login');
    // Continue anyway
  }
  
  // Navigate to team members page
  await page.click('a[href*="/account/teams/"][href*="/memberships"]');
  await page.waitForSelector('.memberships-header');
  helpers.log('Team members page loaded');
  await helpers.screenshot(page, 'vendor-team-members');
  
  // Filter by employee role
  await page.click('#role-filter-employee');
  await page.waitForSelector('.employee-list');
  helpers.log('Employee list loaded');
  await helpers.screenshot(page, 'vendor-employee-list');
  
  // View employee details
  await page.click('a[href*="/memberships/"][href*="/show"]');
  await page.waitForSelector('.membership-details');
  helpers.log('Employee details loaded');
  await helpers.screenshot(page, 'vendor-employee-details');
  
  // View employee training progress
  await page.click('a[href*="/training_progress"]');
  await page.waitForSelector('.training-progress');
  helpers.log('Employee training progress loaded');
  await helpers.screenshot(page, 'vendor-employee-progress');
  
  // View employee certificates
  await page.click('a[href*="/training_certificates"]');
  await page.waitForSelector('.certificates-list');
  helpers.log('Employee certificates loaded');
  await helpers.screenshot(page, 'vendor-employee-certificates');
  
  // Logout
  await page.click('a[href="/users/sign_out"]');
  await page.waitForSelector('a[href="/users/sign_in"]');
  helpers.log('Vendor logged out');
  
  await helpers.sleep(2000);
}

/**
 * Employee completes multiple trainings
 * @param {Page} page - Puppeteer page object
 */
async function employeeCompleteMultipleTrainings(page) {
  helpers.log('Part 5: Employee completes multiple trainings');
  
  // Navigate to login page
  await page.goto(`${config.baseUrl}/users/sign_in`);
  
  // Login as employee
  await page.type('#user_email', config.users.employee.email);
  await page.type('#user_password', config.users.employee.password);
  await page.click('input[type="submit"]');
  helpers.log('Logged in as employee');
  
  // Handle onboarding if needed
  await helpers.handleOnboarding(page, config.users.employee.company);
  
  // Wait for dashboard to load - try multiple possible selectors
  try {
    await Promise.race([
      page.waitForSelector('.dashboard-header', { timeout: 10000 }),
      page.waitForSelector('.dashboard', { timeout: 10000 }),
      page.waitForSelector('.home-header', { timeout: 10000 }),
      page.waitForSelector('h1', { timeout: 10000 })
    ]);
    helpers.log('Employee dashboard or home page loaded');
    await helpers.screenshot(page, 'employee-dashboard-advanced');
  } catch (error) {
    helpers.log('Warning: Could not find dashboard header. Taking screenshot anyway.');
    await helpers.screenshot(page, 'employee-post-login');
    // Continue anyway
  }
  
  // Navigate to training programs
  await page.click('a[href*="/account/teams/"][href*="/training_programs"]');
  await page.waitForSelector('.training-programs-header');
  helpers.log('Training programs page loaded');
  await helpers.screenshot(page, 'employee-training-programs');
  
  // Start the first training program
  await page.click('a[href*="/training_programs/"][href*="/show"]');
  await page.waitForSelector('.training-program-details');
  helpers.log('Training program details loaded');
  await helpers.screenshot(page, 'employee-program-details');
  
  // Start the training
  await page.click('a[href*="/start"]');
  await page.waitForSelector('.training-player');
  helpers.log('Training player loaded');
  await helpers.screenshot(page, 'employee-training-player');
  
  // Complete the training
  await page.click('.complete-training-button');
  await page.waitForSelector('.training-complete');
  helpers.log('Training completed');
  await helpers.screenshot(page, 'employee-training-complete');
  
  // View certificate
  await page.click('a[href*="/training_certificates/"]');
  await page.waitForSelector('.certificate-details');
  helpers.log('Certificate details loaded');
  await helpers.screenshot(page, 'employee-certificate-details');
  
  // Return to training programs
  await page.click('a[href*="/account/teams/"][href*="/training_programs"]');
  await page.waitForSelector('.training-programs-header');
  
  // Start the second training program
  await page.click('a[href*="/training_programs/"][href*="/show"]:nth-child(2)');
  await page.waitForSelector('.training-program-details');
  helpers.log('Second training program details loaded');
  await helpers.screenshot(page, 'employee-second-program-details');
  
  // Start the training
  await page.click('a[href*="/start"]');
  await page.waitForSelector('.training-player');
  helpers.log('Second training player loaded');
  await helpers.screenshot(page, 'employee-second-training-player');
  
  // Complete the training
  await page.click('.complete-training-button');
  await page.waitForSelector('.training-complete');
  helpers.log('Second training completed');
  await helpers.screenshot(page, 'employee-second-training-complete');
  
  // View all certificates
  await page.click('a[href*="/training_certificates"]');
  await page.waitForSelector('.certificates-list');
  helpers.log('All certificates loaded');
  await helpers.screenshot(page, 'employee-all-certificates');
  
  // Logout
  await page.click('a[href="/users/sign_out"]');
  await page.waitForSelector('a[href="/users/sign_in"]');
  helpers.log('Employee logged out');
  
  await helpers.sleep(2000);
}

// Run the demo
runDemo().catch(console.error);