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

// import { initFlowbite } from "flowbite"
// initFlowbite

// import "flowbite/dist/flowbite.turbo.js";
import { initFlowbite, Carousel } from "flowbite/dist/flowbite.turbo.js"
// initFlowbite()

const carouselElement = document.getElementById('carousel-example');

const items = [
    {
        position: 0,
        el: document.getElementById('carousel-item-1'),
    },
    {
        position: 1,
        el: document.getElementById('carousel-item-2'),
    },
    {
        position: 2,
        el: document.getElementById('carousel-item-3'),
    },
    {
        position: 3,
        el: document.getElementById('carousel-item-4'),
    },
];

// options with default values
const options = {
    defaultPosition: 1,
    interval: 3000,

    indicators: {
        activeClasses: 'bg-white dark:bg-gray-800',
        inactiveClasses:
            'bg-white/50 dark:bg-gray-800/50 hover:bg-white dark:hover:bg-gray-800',
        items: [
            {
                position: 0,
                el: document.getElementById('carousel-indicator-1'),
            },
            {
                position: 1,
                el: document.getElementById('carousel-indicator-2'),
            },
            {
                position: 2,
                el: document.getElementById('carousel-indicator-3'),
            },
            {
                position: 3,
                el: document.getElementById('carousel-indicator-4'),
            },
        ],
    },

    // callback functions
    onNext: () => {
        console.log('next slider item is shown');
    },
    onPrev: () => {
        console.log('previous slider item is shown');
    },
    onChange: () => {
        console.log('new slider item has been shown');
    },
};

// instance options object
const instanceOptions = {
  id: 'carousel-example',
  override: true
};

// import { Carousel } from 'flowbite';

const carousel = new Carousel(carouselElement, items, options, instanceOptions);

const $prevButton = document.getElementById('data-carousel-prev');
const $nextButton = document.getElementById('data-carousel-next');

$prevButton.addEventListener('click', () => {
    carousel.prev();
    console.log("Works!", carousel);
});

$nextButton.addEventListener('click', () => {
    carousel.next();
    console.log("Works!", carousel);
});