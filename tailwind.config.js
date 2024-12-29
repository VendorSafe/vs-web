/*
  This configuration file extends Tailwind's default settings.
  Tailwind will generate these classes based on your config:

  1. Font Sizes
    - .text-xs for font-size: 0.81rem
    - .text-2xs for font-size: 0.65rem plus the specified line-height and letter-spacing

  2. Color Palettes
    For each configured color (primary, secondary, accent), you get utilities like:
    - .text-primary-50, .text-primary-100, ..., .bg-primary-200, .border-primary-300, etc.
    - The same pattern applies for .text-secondary-* and .text-accent-* classes, etc.
    This includes background, text, border, ring, placeholder, gradient, etc.
    For example, you'll see .text-primary-700, .bg-secondary-100, .ring-accent-300, etc.

  3. Variants
      - :hover, :active, and :disabled variants for certain utilities, .hover:bg-primary-500,
      .hover:ring-*, .disabled:bg-gray-300, .disabled:cursor-not-allowed
      - This extends to ring classes, letting you do things like .active:ring-offset-2

  4. Plugins
    - @tailwindcss/forms: Generates better default form styles.
    - @tailwindcss/typography: Adds typography utilities (like prose classes).
*/


// For reference: https://tailwindcss.com/docs/configuration

// Import default Tailwind theme for extension
const defaultTheme = require('tailwindcss/defaultTheme')
// Provide color definitions from Tailwind
const colors = require('tailwindcss/colors')

/** @type {import('tailwindcss').Config} */
module.exports = {
  mode: 'jit', // Enable JIT mode
  // The `content` array specifies which files Tailwind checks for class usage:
  // https://tailwindcss.com/docs/content-configuration
  content: [
    "./node_modules/flowbite/**/*.js",
    './config/initializers/theme.rb',
    './app/views/**/*.html.{erb,slim,haml}',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js',
    './tmp/gems/*/app/views/**/*.html.erb',
    './tmp/gems/*/app/helpers/**/*.rb',
    './tmp/gems/*/app/assets/stylesheets/**/*.css',
    './tmp/gems/*/app/javascript/**/*.js',
    './app/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/javascript/**/*.jsx',
    './app/components/**/*.{js,jsx,rb,erb,haml,slim}',
    './app/views/**/*.{html.erb,html.haml,html.slim}',
    './lib/**/*.{rb,erb}',
    './config/**/*.yml',
    // Add other paths as needed
  ],
  // `darkMode` can be set to 'media', 'class', or 'false'. Here, it uses system settings.
  // darkMode: false,
  // The `theme` object allows you to override or extend default Tailwind values.
  // https://tailwindcss.com/docs/theme
  theme: {
    // `extend` merges your additions with the default theme.
    extend: {
      // Provide additional size values in `fontSize`.
      fontSize: {
        'xs': '.81rem',
        '2xs': ['0.65rem', { lineHeight: '0.9rem', letterSpacing: '1px' }]
      },
      // Define a custom color palette using CSS variables.
      // https://tailwindcss.com/docs/customizing-colors
      colors: {
        primary: {
          50: 'var(--primary-50)',
          100: 'var(--primary-100)',
          200: 'var(--primary-200)',
          300: 'var(--primary-300)',
          400: 'var(--primary-400)',
          500: 'var(--primary-500)',
          600: 'var(--primary-600)',
          700: 'var(--primary-700)',
          800: 'var(--primary-800)',
          900: 'var(--primary-900)',
        },

        secondary: {
          50: 'var(--secondary-50)',
          100: 'var(--secondary-100)',
          200: 'var(--secondary-200)',
          300: 'var(--secondary-300)',
          400: 'var(--secondary-400)',
          500: 'var(--secondary-500)',
          600: 'var(--secondary-600)',
          700: 'var(--secondary-700)',
          800: 'var(--secondary-800)',
          900: 'var(--secondary-900)',
        },
        accent: {
          50: 'var(--accent-50)',
          100: 'var(--accent-100)',
          200: 'var(--accent-200)',
          300: 'var(--accent-300)',
          400: 'var(--accent-400)',
          500: 'var(--accent-500)',
          600: 'var(--accent-600)',
          700: 'var(--accent-700)',
          800: 'var(--accent-800)',
          900: 'var(--accent-900)',
        },
      },
      // Merge custom fonts with Tailwind’s default font stack.
      fontFamily: {
        // sans: [
        //   'Avenir Next W01',
        //   'Proxima Nova W01',
        //   '-apple-system',
        //   'system-ui',
        //   'BlinkMacSystemFont',
        //   'Segoe UI',
        //   'Roboto',
        //   'Helvetica Neue',
        //   'Arial',
        //   'sans-serif',
        //   ...defaultTheme.fontFamily.sans,
        // ],
        serif: ['Instrument Serif', 'Georgia', 'serif'],
      },
    },
  },
  // Specify how variants (hover, focus, disabled, etc.) should apply to utilities.
  variants: {
    extend: {
      backgroundColor: ['disabled'],
      cursor: ['disabled'],
      opacity: ['disabled'],
      textColor: ['disabled'],
      ringWidth: ['hover', 'active'],
      ringColor: ['hover', 'active'],
      ringOffsetWidth: ['hover', 'active'],
      ringOffsetColor: ['hover', 'active'],
      ringOpacity: ['hover', 'active'],
    },
  },
  // Specify any Tailwind plugins to enable extra utilities or components.
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('flowbite/plugin')
  ],
}