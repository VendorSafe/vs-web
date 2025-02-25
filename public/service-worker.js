// Training Program Viewer Service Worker
const CACHE_NAME = 'training-program-viewer-cache-v1';
const RUNTIME_CACHE = 'training-program-viewer-runtime';

// Resources to cache on install
const PRECACHE_URLS = [
  '/offline.html',
  '/assets/images/offline-logo.png',
  '/assets/fonts/OpenSans-Regular.ttf',
  '/assets/fonts/OpenSans-Bold.ttf'
];

// Install event - precache static assets
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(PRECACHE_URLS))
      .then(self.skipWaiting())
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', event => {
  const currentCaches = [CACHE_NAME, RUNTIME_CACHE];
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return cacheNames.filter(cacheName => !currentCaches.includes(cacheName));
    }).then(cachesToDelete => {
      return Promise.all(cachesToDelete.map(cacheToDelete => {
        return caches.delete(cacheToDelete);
      }));
    }).then(() => self.clients.claim())
  );
});

// Fetch event - network-first strategy with fallback to cache
self.addEventListener('fetch', event => {
  // Skip cross-origin requests
  if (!event.request.url.startsWith(self.location.origin)) {
    return;
  }

  // API requests - network first, then cache
  if (event.request.url.includes('/api/')) {
    event.respondWith(
      fetch(event.request)
        .then(response => {
          // Cache the response for future use
          const responseToCache = response.clone();
          caches.open(RUNTIME_CACHE)
            .then(cache => {
              cache.put(event.request, responseToCache);
            });
          return response;
        })
        .catch(() => {
          // If network fails, try to serve from cache
          return caches.match(event.request)
            .then(cachedResponse => {
              if (cachedResponse) {
                return cachedResponse;
              }
              
              // If it's a training program request, return a default offline response
              if (event.request.url.includes('/training_programs/')) {
                return caches.match('/offline.html');
              }
              
              return new Response(JSON.stringify({
                error: 'You are offline and this resource is not cached.'
              }), {
                headers: { 'Content-Type': 'application/json' }
              });
            });
        })
    );
    return;
  }

  // HTML requests - network first, then cache
  if (event.request.headers.get('Accept').includes('text/html')) {
    event.respondWith(
      fetch(event.request)
        .then(response => {
          // Cache the response for future use
          const responseToCache = response.clone();
          caches.open(RUNTIME_CACHE)
            .then(cache => {
              cache.put(event.request, responseToCache);
            });
          return response;
        })
        .catch(() => {
          return caches.match(event.request)
            .then(cachedResponse => {
              return cachedResponse || caches.match('/offline.html');
            });
        })
    );
    return;
  }

  // Images, scripts, styles - cache first, then network
  if (
    event.request.url.match(/\.(js|css|png|jpg|jpeg|gif|svg|woff|woff2|ttf|eot)$/)
  ) {
    event.respondWith(
      caches.match(event.request)
        .then(cachedResponse => {
          return cachedResponse || fetch(event.request)
            .then(response => {
              // Cache the response for future use
              const responseToCache = response.clone();
              caches.open(RUNTIME_CACHE)
                .then(cache => {
                  cache.put(event.request, responseToCache);
                });
              return response;
            })
            .catch(error => {
              // Special handling for images
              if (event.request.url.match(/\.(png|jpg|jpeg|gif|svg)$/)) {
                return caches.match('/assets/images/offline-logo.png');
              }
              throw error;
            });
        })
    );
    return;
  }

  // Default - network first with cache fallback
  event.respondWith(
    fetch(event.request)
      .then(response => {
        // Cache the response for future use
        const responseToCache = response.clone();
        caches.open(RUNTIME_CACHE)
          .then(cache => {
            cache.put(event.request, responseToCache);
          });
        return response;
      })
      .catch(() => {
        return caches.match(event.request);
      })
  );
});

// Background sync for pending updates
self.addEventListener('sync', event => {
  if (event.tag === 'sync-training-progress') {
    event.waitUntil(syncTrainingProgress());
  }
});

// Function to sync pending training progress updates
async function syncTrainingProgress() {
  try {
    // Get all clients
    const clients = await self.clients.matchAll();
    
    // Send message to client to sync pending updates
    clients.forEach(client => {
      client.postMessage({
        type: 'SYNC_PENDING_UPDATES'
      });
    });
    
    return true;
  } catch (error) {
    console.error('Error syncing training progress:', error);
    return false;
  }
}

// Listen for messages from clients
self.addEventListener('message', event => {
  if (event.data && event.data.type === 'CACHE_TRAINING_PROGRAM') {
    const { programId, data } = event.data;
    
    // Cache the training program data
    caches.open(RUNTIME_CACHE)
      .then(cache => {
        const url = `/api/v1/training_programs/${programId}`;
        const response = new Response(JSON.stringify(data), {
          headers: { 'Content-Type': 'application/json' }
        });
        cache.put(new Request(url), response);
      });
  }
});