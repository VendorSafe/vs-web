#!/usr/bin/env node

/**
 * VendorSafe Training Platform Demo Script
 * 
 * This script demonstrates the complete workflow of the VendorSafe training platform,
 * showing interactions between different roles (admin, customer, vendor, employee)
 * throughout the lifecycle of a training program.
 * 
 * Usage:
 * node bin/demo-script.js
 * 
 * Requirements:
 * - npm install puppeteer
 * - A running instance of the VendorSafe application
 */

const puppeteer = require('puppeteer');

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
      name: 'Admin User'
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
      name: 'Employee User'
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
  }
};

/**
 * Main demo function
 */
async function runDemo() {
  helpers.log('Starting VendorSafe Training Platform Demo');
  
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
    
    // Create screenshots directory if it doesn't exist
    const fs = require('fs');
    if (!fs.existsSync('screenshots')) {
      fs.mkdirSync('screenshots');
    }
    
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
  
  // Wait for dashboard to load
  await page.waitForSelector('.dashboard-header');
  helpers.log('Admin dashboard loaded');
  await helpers.screenshot(page, 'admin-dashboard');
  
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
  
  // Wait for dashboard to load
  await page.waitForSelector('.dashboard-header');
  helpers.log('Customer dashboard loaded');
  await helpers.screenshot(page, 'customer-dashboard');
  
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
  
  // Wait for dashboard
  await page.waitForSelector('.dashboard-header');
  await helpers.screenshot(page, 'vendor-registered');
  
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
  
  // Wait for dashboard
  await page.waitForSelector('.dashboard-header');
  await helpers.screenshot(page, 'employee-registered');
  
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

// Run the demo
runDemo().catch(console.error);