<script setup>
import { onMounted, computed, ref, watch } from "vue";
import { useTrainingProgramStore } from "./useTrainingProgramStore";
import VideoPlayer from "./VideoPlayer.vue";
import QuestionsPanel from "./QuestionsPanel.vue";
import StepProgress from "./StepProgress.vue";
import CertificateViewer from "./CertificateViewer.vue";

const props = defineProps({
  programId: {
    type: String,
    required: true,
  },
  userName: {
    type: String,
    default: "",
  },
});

const store = useTrainingProgramStore();
const showFilters = ref(false);
const contentTypeFilter = ref("all");
const searchQuery = ref("");
const networkStatus = ref(navigator.onLine ? "online" : "offline");
const showOfflineNotice = ref(false);

// Listen for online/offline events
onMounted(() => {
  window.addEventListener("online", handleNetworkChange);
  window.addEventListener("offline", handleNetworkChange);
  
  // Check for pending updates when coming back online
  if (networkStatus.value === "online") {
    store.syncPendingUpdates();
  }
});

// Clean up event listeners
onUnmounted(() => {
  window.removeEventListener("online", handleNetworkChange);
  window.removeEventListener("offline", handleNetworkChange);
});

const handleNetworkChange = () => {
  const newStatus = navigator.onLine ? "online" : "offline";
  
  // If transitioning from offline to online
  if (networkStatus.value === "offline" && newStatus === "online") {
    store.setOfflineMode(false);
    store.syncPendingUpdates();
  }
  
  // If transitioning from online to offline
  if (networkStatus.value === "online" && newStatus === "offline") {
    store.setOfflineMode(true);
    showOfflineNotice.value = true;
    setTimeout(() => {
      showOfflineNotice.value = false;
    }, 5000);
  }
  
  networkStatus.value = newStatus;
};

const currentContent = computed(() => store.currentContent);
const isLoading = computed(() => store.isLoading);
const error = computed(() => store.error);
const trainingProgram = computed(() => store.trainingProgram);
const isComplete = computed(() => store.isComplete);
const completionPercentage = computed(() => store.completionPercentage);
const hasCertificate = computed(() => store.hasCertificate);
const certificate = computed(() => store.certificate);
const certificateLoading = computed(() => store.certificateLoading);

const isVideoContent = computed(
  () => currentContent.value?.content_type === "video"
);

const currentQuestions = computed(
  () => currentContent.value?.training_questions || []
);

// Filtered contents based on search and content type
const filteredContents = computed(() => {
  if (!trainingProgram.value?.training_contents) return [];
  
  return trainingProgram.value.training_contents.filter(content => {
    // Filter by content type
    if (contentTypeFilter.value !== "all" && content.content_type !== contentTypeFilter.value) {
      return false;
    }
    
    // Filter by search query
    if (searchQuery.value) {
      const query = searchQuery.value.toLowerCase();
      return (
        content.title.toLowerCase().includes(query) ||
        content.body.toLowerCase().includes(query)
      );
    }
    
    return true;
  });
});

onMounted(async () => {
  await store.fetchTrainingProgram(props.programId);
  
  // If program is complete, fetch certificate
  if (store.isComplete) {
    store.fetchCertificate();
  }
});

// Watch for completion to fetch certificate
watch(isComplete, (newValue) => {
  if (newValue && !hasCertificate.value) {
    store.fetchCertificate();
  }
});

const handleVideoComplete = () => {
  if (currentContent.value) {
    store.updateProgress(currentContent.value.id, { completed: true });
  }
};

const handleQuestionsComplete = () => {
  if (currentContent.value) {
    store.updateProgress(currentContent.value.id, { completed: true });

    // Move to next content if available
    if (
      store.currentContentIndex <
      trainingProgram.value.training_contents.length - 1
    ) {
      store.nextContent();
    }
  }
};

const handleStepSelected = (index) => {
  store.setCurrentContentIndex(index);
};

const handleGenerateCertificate = () => {
  store.generateCertificate();
};

const toggleFilters = () => {
  showFilters.value = !showFilters.value;
};

const resetFilters = () => {
  contentTypeFilter.value = "all";
  searchQuery.value = "";
};

const applyFilters = () => {
  // If filtered contents include the current content, keep it selected
  // Otherwise, select the first filtered content
  const currentContentIndex = filteredContents.value.findIndex(
    content => content.id === currentContent.value?.id
  );
  
  if (currentContentIndex === -1 && filteredContents.value.length > 0) {
    // Find the index in the original array
    const newIndex = trainingProgram.value.training_contents.findIndex(
      content => content.id === filteredContents.value[0].id
    );
    store.setCurrentContentIndex(newIndex);
  }
  
  showFilters.value = false;
};
</script>

<template>
  <div class="training-program-viewer bg-gradient-light min-h-screen">
    <!-- Offline Notice -->
    <div
      v-if="showOfflineNotice"
      class="fixed top-4 right-4 bg-yellow-100 border border-yellow-400 text-yellow-700 px-4 py-3 rounded z-50 shadow-lg"
    >
      <div class="flex items-center">
        <svg class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
        </svg>
        <span>You are now working offline. Changes will be synced when you reconnect.</span>
      </div>
    </div>

    <!-- Network Status Indicator -->
    <div class="absolute top-4 left-4 flex items-center">
      <span
        class="inline-block w-3 h-3 rounded-full mr-2"
        :class="networkStatus === 'online' ? 'bg-green-500' : 'bg-red-500'"
      ></span>
      <span class="text-sm text-gray-600">{{ networkStatus === 'online' ? 'Online' : 'Offline' }}</span>
    </div>

    <div v-if="isLoading" class="text-center py-16">
      <div class="loading-spinner mx-auto"></div>
      <p class="mt-4 text-gray-600 animate-pulse">
        Loading training program...
      </p>
    </div>

    <div v-else-if="error" class="text-center py-16">
      <div
        class="max-w-md mx-auto card card-body bg-red-50 border border-red-200"
      >
        <p class="text-red-600">{{ error }}</p>
      </div>
    </div>

    <div v-else-if="trainingProgram" class="space-y-12 fade-in">
      <!-- Program Header -->
      <div class="program-header card card-body">
        <div class="flex flex-col md:flex-row justify-between items-center">
          <div>
            <h1 class="text-2xl md:text-3xl font-bold text-secondary-800">
              {{ trainingProgram.name }}
            </h1>
            <p class="text-gray-600 mt-2">{{ trainingProgram.description }}</p>
          </div>
          
          <div class="mt-4 md:mt-0 flex flex-col items-center">
            <div class="progress-circle">
              <svg width="80" height="80" viewBox="0 0 80 80">
                <circle
                  cx="40"
                  cy="40"
                  r="36"
                  fill="none"
                  stroke="#e5e7eb"
                  stroke-width="8"
                />
                <circle
                  cx="40"
                  cy="40"
                  r="36"
                  fill="none"
                  stroke="#4f46e5"
                  stroke-width="8"
                  stroke-dasharray="226.2"
                  :stroke-dashoffset="226.2 - (226.2 * completionPercentage) / 100"
                  transform="rotate(-90 40 40)"
                />
                <text x="40" y="45" text-anchor="middle" font-size="16" font-weight="bold">
                  {{ completionPercentage }}%
                </text>
              </svg>
            </div>
            <span class="text-sm text-gray-600 mt-2">Completion</span>
          </div>
        </div>
      </div>

      <!-- Certificate View (when program is complete) -->
      <div v-if="isComplete && certificate" class="certificate-section fade-in">
        <div class="card card-body bg-green-50 border border-green-200 mb-8">
          <div class="flex items-center">
            <svg class="h-8 w-8 text-green-500 mr-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <div>
              <h3 class="text-xl font-bold text-green-800">Congratulations!</h3>
              <p class="text-green-700">You have successfully completed this training program.</p>
            </div>
          </div>
        </div>
        
        <CertificateViewer
          :certificate-id="certificate.id"
          :training-program="trainingProgram"
          :user-name="userName"
        />
      </div>
      
      <!-- Certificate Generation (when complete but no certificate) -->
      <div v-else-if="isComplete && !certificate && !certificateLoading" class="text-center py-8 card card-body">
        <h3 class="text-xl font-bold text-secondary-800 mb-4">Training Complete!</h3>
        <p class="text-gray-600 mb-6">You have successfully completed all the training content.</p>
        <button @click="handleGenerateCertificate" class="btn btn-primary">
          Generate Certificate
        </button>
      </div>
      
      <!-- Certificate Loading -->
      <div v-else-if="certificateLoading" class="text-center py-8">
        <div class="loading-spinner mx-auto"></div>
        <p class="mt-4 text-gray-600">Generating your certificate...</p>
      </div>

      <!-- Content Navigation and Filters -->
      <div v-if="!isComplete || !certificate" class="filters-container">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-xl font-bold text-secondary-800">Training Content</h3>
          
          <button @click="toggleFilters" class="btn btn-secondary btn-sm">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
            </svg>
            Filters
          </button>
        </div>
        
        <!-- Filters Panel -->
        <div v-if="showFilters" class="filters-panel card card-body mb-6 fade-in">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Content Type</label>
              <select v-model="contentTypeFilter" class="form-input">
                <option value="all">All Types</option>
                <option value="video">Video</option>
                <option value="text">Text</option>
                <option value="quiz">Quiz</option>
              </select>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Search</label>
              <input
                type="text"
                v-model="searchQuery"
                placeholder="Search content..."
                class="form-input"
              />
            </div>
          </div>
          
          <div class="flex justify-end mt-6 space-x-4">
            <button @click="resetFilters" class="btn btn-secondary btn-sm">
              Reset
            </button>
            <button @click="applyFilters" class="btn btn-primary btn-sm">
              Apply Filters
            </button>
          </div>
        </div>

        <StepProgress
          :contents="filteredContents.length > 0 ? filteredContents : trainingProgram.training_contents"
          :current-index="store.currentContentIndex"
          :progress="trainingProgram.progress"
          @step-selected="handleStepSelected"
        />

        <div v-if="currentContent" class="content-container card fade-in">
          <div class="card-body">
            <h2
              class="text-3xl md:text-4xl font-bold mb-8 text-center text-secondary-800"
            >
              {{ currentContent.title }}
            </h2>

            <div
              v-if="isVideoContent"
              class="mb-8 rounded-xl overflow-hidden shadow-lg"
            >
              <VideoPlayer
                :video-url="currentContent.body"
                @completed="handleVideoComplete"
              />
            </div>

            <div v-else class="prose max-w-none mb-8 text-gray-600">
              <div v-html="currentContent.body"></div>
            </div>

            <QuestionsPanel
              v-if="currentQuestions.length > 0"
              :questions="currentQuestions"
              @completed="handleQuestionsComplete"
              class="mt-12"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.training-program-viewer {
  @apply container mx-auto px-6 py-12;
}

.content-container {
  @apply max-w-4xl mx-auto;
}

.filters-container {
  @apply max-w-4xl mx-auto;
}

.program-header {
  @apply max-w-4xl mx-auto;
}

.certificate-section {
  @apply max-w-4xl mx-auto;
}

.prose {
  @apply space-y-6;
}

.prose h2 {
  @apply text-2xl font-bold text-secondary-800 mb-4;
}

.prose p {
  @apply text-gray-600 leading-relaxed;
}

.prose ul {
  @apply list-disc list-inside space-y-2 text-gray-600;
}

.prose img {
  @apply rounded-lg shadow-md my-6;
}

.progress-circle {
  @apply relative;
}

.progress-circle svg {
  @apply transform -rotate-90;
}

.progress-circle text {
  @apply transform rotate-90;
}

:deep(.btn) {
  @apply inline-flex items-center justify-center px-6 py-3 rounded-full font-medium transition-all duration-200;
}

:deep(.btn-sm) {
  @apply px-4 py-2 text-sm;
}

:deep(.btn-primary) {
  @apply bg-primary-500 text-white hover:bg-primary-600 hover:scale-105;
}

:deep(.btn-secondary) {
  @apply border-2 border-secondary-500 text-secondary-500 hover:bg-secondary-500 hover:text-white;
}

:deep(.form-input) {
  @apply w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all duration-200;
}

:deep(.badge) {
  @apply inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium;
}

:deep(.badge-success) {
  @apply bg-green-100 text-green-800;
}

:deep(.badge-warning) {
  @apply bg-yellow-100 text-yellow-800;
}

.fade-in {
  animation: fadeIn 0.5s ease-in-out;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}
</style>
