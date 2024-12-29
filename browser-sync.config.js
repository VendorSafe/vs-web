module.exports = {
  // **Files to Watch**
  // Specifies files or directories to monitor for changes.
  // Changes in these files will trigger actions like injecting CSS or reloading the browser.
  // files: ["app/css/**/*.css", "app/js/**/*.js"],

  // **Server Configuration**
  // Defines whether to use a static server and the directories to serve.
  // Useful for simple static sites without a backend.
  // server: {
  //   baseDir: "app", // The root directory for the static server.
  //   directory: true // Enables directory listing in the browser.
  // },

  // **Proxy Configuration**
  // Proxies an existing backend server. Use this for projects with a backend like PHP, Node.js, or Rails.
  proxy: "127.0.0.1:3000",


  host: "localhost",

  // **Port**
  // Sets the port number for the Browsersync server. Default is 3000.
  port: 4000,

  // **UI Configuration**
  // Configures the Browsersync user interface (accessible via a separate port).
  // ui: {
  //   port: 8080, // Port for the UI interface.
  //   weinre: {
  //     port: 9090 // Port for remote debugging (optional).
  //   }
  // },

  // **Ghost Mode**
  // Synchronizes interactions (e.g., clicks, scrolls, form inputs) across connected devices.
  // ghostMode: {
  //   clicks: true,   // Syncs clicks on links and buttons.
  //   forms: true,    // Syncs form inputs and submissions.
  //   scroll: true    // Syncs scrolling between devices.
  // },

  // **Open Browser**
  // Automatically opens a browser window when Browsersync starts.
  // open: "local", // Options: "local", "external", "ui", "ui-external", "tunnel", or false.
  open: "external", // Options: "local", "external", "ui", "ui-external", "tunnel", or false.

  // **Notifications**
  // Toggles in-browser notifications for file changes and other events.
  // notify: false,

  // **Static File Serving**
  // Adds additional directories from which static files can be served.
  // serveStaticOptions: {
  //   extensions: ['html'] // Enables pretty URLs (e.g., `/about` instead of `/about.html`).
  // },

  // **HTTPS**
  // Enables HTTPS for local development. You can also specify custom certificates.
  // https: false,

  // **Reload Delay**
  // Adds a delay (in milliseconds) before reloading the browser after detecting changes.
  // reloadDelay: 1000,

  // **Reload Debounce**
  // Waits for a specified period of event silence before triggering a reload.
  // reloadDebounce: 500,

  // **Log Level**
  // Controls verbosity of logs in the terminal. Options are "info", "debug", "warn", or "silent".
  // logLevel: "debug",

  // **Log Connections**
  // Logs each device connection to the Browsersync server.
  // logConnections: true,

  // **Browser Selection**
  // Specifies which browsers to open. Defaults to the system's default browser if not set.
  // browser: ["google chrome"],

  // **CORS Headers**
  // Adds HTTP access control headers to assets served by Browsersync (useful for cross-origin requests).
  // cors: true,

  // **Code Sync**
  // Toggles whether file-change events are sent to browsers. Disabling this prevents automatic updates in browsers.
  // codeSync: true,

  // **Scroll Restoration Technique**
  // scrollRestoreTechnique: "window.name",

  // **Middleware**
  // Specifies middleware functions to run before requests are served.
  // Useful for adding custom logic like authentication or modifying requests.
  // middleware: [
  //   function (req, res, next) {
  //     console.log("Request URL:", req.url);
  //     next();
  //   }
  // ],

  // // **Rewrite Rules**
  // // Allows you to define custom rewrite rules for modifying HTML or other responses.
  // rewriteRules: [
  //   {
  //     match: /<\/body>/i,
  //     fn: function (req, res, match) {
  //       return '<script>alert("Custom script injected!")</script>' + match;
  //     }
  //   }
  // ],

  // // **Snippet Options**
  // // Configures how and where the Browsersync script is injected into your HTML.
  // snippetOptions: {
  //   rule: {
  //     match: /<\/body>/i, // Injects the script before the closing </body> tag.
  //     fn: function (snippet, match) {
  //       return snippet + match;
  //     }
  //   }
  // },

  // **Tunnel**
  // Creates a public URL for your local site using a tunneling service.
  // tunnel: true, // Set to true or provide a string for a custom subdomain.

  // **Ignore Paths**
  // Specifies files or directories that Browsersync should ignore when watching for changes.
  // ignore: [
  //   "node_modules",
  //   "tmp",
  //   ".git"
  // ],

  // // **Reload Throttle**
  // // Limits the number of reloads per second to avoid excessive reloading during rapid file changes.
  // reloadThrottle: 100,

  // // **Client-Side Events**
  // // Toggles specific client-side events like scroll syncing and form input syncing.
  // clientEvents: ["scroll", "click", "input"],

  // // **Tag Names**
  // // Defines custom tag names for injecting scripts and styles into your HTML.
  // tagNames: {
  //   css: "<link rel='stylesheet' href='%s'>",
  //   js: "<script src='%s'></script>"
  // }
};

/*
Possible issues when using Browsersync with Bullet Train, esbuild, PostCSS, TailwindCSS, etc.:
1. **Bullet Train**:
 - Bullet Train uses Rails conventions, so ensure `proxy` is set correctly to the Rails server (e.g., `http://localhost:3000`).
 - Asset pipeline conflicts may occur if Browsersync tries to serve files that Rails also handles.

2. **esbuild**:
 - Ensure esbuild outputs files to a directory that Browsersync watches (`files` or `serveStatic`).
 - If esbuild uses an in-memory server, you may need to proxy it instead of using static file serving.

3. **PostCSS**:
 - PostCSS watchers may conflict with Browsersync's file watching. Ensure only one tool is responsible for watching and processing CSS files.

4. **TailwindCSS**:
 - Tailwind's JIT mode generates styles dynamically. Ensure `files` includes all template files (e.g., `.html`, `.erb`, `.jsx`) so Tailwind regenerates styles on changes.
 - If using PostCSS with Tailwind, ensure Browsersync watches the compiled CSS output directory.

5. **General File Watching**:
 - Watching too many files can slow down performance. Use specific paths in `files` to avoid unnecessary overhead.

6. **CORS Issues**:
 - If your app makes cross-origin requests (e.g., API calls), enable `cors` in Browsersync or configure your backend to allow CORS.

7. **HTTPS Conflicts**:
 - If your backend uses HTTPS, ensure Browsersync's `https` option is enabled and matches the backend's certificate setup.

8. **Live Reloading**:
 - Tailwind's hot-reloading may conflict with Browsersync's reload behavior. Disable `injectChanges` if you encounter issues with CSS injection.

By addressing these potential conflicts and configuring Browsersync properly, you can create a smooth development workflow across all these tools.
*/