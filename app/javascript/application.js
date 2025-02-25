// 🚫 DEFAULT RAILS INCLUDES
// This section represents the default includes for a Rails application. Bullet Train's includes and your own
// includes should be specified at the end of the file, not in this section. This helps avoid merge conflicts in the
// future should the framework defaults change.

import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "@hotwired/turbo-rails"
import "./controllers"
import "./channels"

Rails.start()
ActiveStorage.start()

// 🚫 DEFAULT BULLET TRAIN INCLUDES
// This section represents the default settings for a Bullet Train application. Your own includes should be specified
// at the end of the file. This helps avoid merge conflicts in the future, should we need to change our own includes.

import "./support/jstz";

import "@bullet-train/bullet-train"
import "@bullet-train/bullet-train-sortable"

require("@icon/themify-icons/themify-icons.css")

import { trixEditor } from "@bullet-train/fields"
trixEditor()

// ✅ YOUR APPLICATION'S INCLUDES
// If you need to customize your application's includes, this is the place to do it. This helps avoid merge
// conflicts in the future when Rails or Bullet Train update their own default includes.

// Import Flowbite with Turbo support
import * as FlowbiteModule from "flowbite"

// Make Flowbite available globally for Stimulus controllers
window.Flowbite = FlowbiteModule;

// Initialize Flowbite components after Turbo navigation
document.addEventListener("turbo:load", () => {
  // Initialize all Flowbite components
  window.Flowbite.initFlowbite();
});

// Handle mobile web app meta tag
document.addEventListener("DOMContentLoaded", () => {
  const appleMetaTag = document.querySelector('meta[name="apple-mobile-web-app-capable"]');
  if (appleMetaTag) {
    const mobileMetaTag = document.createElement('meta');
    mobileMetaTag.name = 'mobile-web-app-capable';
    mobileMetaTag.content = 'yes';
    document.head.appendChild(mobileMetaTag);
  }
});

// Register service worker for offline support
import { registerServiceWorker } from "./training-program-viewer/register-service-worker";

// Register service worker if on a training program page
document.addEventListener("turbo:load", () => {
  if (document.querySelector('.training-program-viewer')) {
    registerServiceWorker();
  }
});

// Copy service worker to public directory
if (process.env.NODE_ENV === 'production') {
  const fs = require('fs');
  const path = require('path');
  
  try {
    const sourceFile = path.resolve(__dirname, 'training-program-viewer/service-worker.js');
    const destFile = path.resolve(__dirname, '../../public/service-worker.js');
    
    if (fs.existsSync(sourceFile)) {
      fs.copyFileSync(sourceFile, destFile);
      console.log('Service worker copied to public directory');
    }
  } catch (error) {
    console.error('Error copying service worker:', error);
  }
}