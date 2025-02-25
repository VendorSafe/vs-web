// Service Worker Registration
export function registerServiceWorker() {
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
      navigator.serviceWorker.register('/service-worker.js')
        .then(registration => {
          console.log('Service Worker registered with scope:', registration.scope);
          
          // Set up sync when back online
          window.addEventListener('online', () => {
            if (registration.sync) {
              registration.sync.register('sync-training-progress')
                .catch(error => console.error('Error registering sync:', error));
            }
          });
          
          // Listen for messages from the service worker
          navigator.serviceWorker.addEventListener('message', event => {
            if (event.data && event.data.type === 'SYNC_PENDING_UPDATES') {
              // Dispatch an event that the store can listen for
              window.dispatchEvent(new CustomEvent('sync-training-progress'));
            }
          });
        })
        .catch(error => {
          console.error('Service Worker registration failed:', error);
        });
    });
  }
}

// Cache a training program for offline use
export function cacheTrainingProgram(programId, data) {
  if ('serviceWorker' in navigator && navigator.serviceWorker.controller) {
    navigator.serviceWorker.controller.postMessage({
      type: 'CACHE_TRAINING_PROGRAM',
      programId,
      data
    });
  }
}

// Request background sync
export function requestBackgroundSync() {
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.ready
      .then(registration => {
        if (registration.sync) {
          return registration.sync.register('sync-training-progress');
        }
        return Promise.resolve();
      })
      .catch(error => {
        console.error('Error registering background sync:', error);
      });
  }
}

// Check if the browser is online
export function isOnline() {
  return navigator.onLine;
}

// Add event listeners for online/offline status
export function setupNetworkListeners(callbacks) {
  const { onOnline, onOffline } = callbacks || {};
  
  window.addEventListener('online', () => {
    console.log('Application is online');
    if (typeof onOnline === 'function') {
      onOnline();
    }
    requestBackgroundSync();
  });
  
  window.addEventListener('offline', () => {
    console.log('Application is offline');
    if (typeof onOffline === 'function') {
      onOffline();
    }
  });
  
  // Listen for sync events from the service worker
  window.addEventListener('sync-training-progress', () => {
    if (typeof onOnline === 'function') {
      onOnline();
    }
  });
  
  return {
    isOnline: isOnline()
  };
}