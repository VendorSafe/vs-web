<template>
  <div class="training-player">
    <!-- Loading State -->
    <div v-if="isLoading" class="loading-overlay">
      <div class="spinner"></div>
      <p>Loading training content...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-message">
      <p>{{ error }}</p>
      <button @click="retryLoading" class="retry-button">Retry</button>
    </div>

    <!-- Main Content -->
    <div v-else class="training-content">
      <!-- Progress Bar -->
      <progress-bar
        :percentage="completionPercentage"
        :current-module="currentModuleIndex + 1"
        :total-modules="modules.length"
      />

      <!-- Module Navigation -->
      <div class="module-navigation">
        <button
          v-for="(module, index) in modules"
          :key="module.id"
          :class="['module-button', { active: currentModuleIndex === index }]"
          @click="setCurrentModule(module.id)"
          :disabled="!canAccessModule(index)"
        >
          {{ module.title }}
        </button>
      </div>

      <!-- Current Module Content -->
      <div v-if="currentModule" class="module-content">
        <!-- Video Player -->
        <video-player
          v-if="currentModule.type === 'video'"
          :src="currentModule.content"
          :current-time="progress.currentPosition"
          @timeupdate="handleTimeUpdate"
          @complete="handleVideoComplete"
        />

        <!-- Document Viewer -->
        <div
          v-else-if="currentModule.type === 'document'"
          class="document-viewer"
        >
          <div v-html="currentModule.content"></div>
          <button @click="markCurrentModuleComplete" class="complete-button">
            Mark as Complete
          </button>
        </div>

        <!-- Quiz -->
        <question-list
          v-else-if="currentModule.type === 'quiz'"
          :questions="currentModule.questions"
          @complete="handleQuizComplete"
        />
      </div>

      <!-- Navigation Controls -->
      <div class="navigation-controls">
        <button
          @click="previousModule"
          :disabled="currentModuleIndex === 0"
          class="nav-button"
        >
          Previous
        </button>
        <button
          @click="nextModule"
          :disabled="!canMoveToNextModule"
          class="nav-button"
        >
          Next
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { defineComponent, onMounted, computed } from "vue";
import { useTrainingStore } from "../stores/trainingStore";
import VideoPlayer from "./VideoPlayer.vue";
import QuestionList from "./QuestionList.vue";
import ProgressBar from "./ProgressBar.vue";

export default defineComponent({
  name: "TrainingPlayer",

  components: {
    VideoPlayer,
    QuestionList,
    ProgressBar,
  },

  props: {
    programId: {
      type: String,
      required: true,
    },
  },

  setup(props) {
    const store = useTrainingStore();

    // Computed properties
    const canMoveToNextModule = computed(() => {
      const currentIndex = store.currentModuleIndex;
      if (currentIndex === -1 || currentIndex >= store.modules.length - 1)
        return false;
      return store.progress.completedModules.includes(store.currentModule?.id);
    });

    const canAccessModule = (index) => {
      if (index === 0) return true;
      const previousModule = store.modules[index - 1];
      return store.progress.completedModules.includes(previousModule.id);
    };

    // Methods
    const loadTrainingContent = async () => {
      try {
        store.isLoading = true;
        const response = await fetch(`/api/training/${props.programId}`);
        if (!response.ok) throw new Error("Failed to load training content");
        const data = await response.json();
        store.setModules(data.modules);
      } catch (e) {
        store.error = e.message;
      } finally {
        store.isLoading = false;
      }
    };

    const handleTimeUpdate = (time) => {
      store.updatePosition(time);
    };

    const handleVideoComplete = () => {
      store.markModuleComplete(store.currentModule.id);
    };

    const handleQuizComplete = (score) => {
      if (score >= store.currentModule.passingScore) {
        store.markModuleComplete(store.currentModule.id);
      }
    };

    const nextModule = () => {
      if (canMoveToNextModule.value) {
        const nextIndex = store.currentModuleIndex + 1;
        store.setCurrentModule(store.modules[nextIndex].id);
      }
    };

    const previousModule = () => {
      if (store.currentModuleIndex > 0) {
        const prevIndex = store.currentModuleIndex - 1;
        store.setCurrentModule(store.modules[prevIndex].id);
      }
    };

    const markCurrentModuleComplete = () => {
      store.markModuleComplete(store.currentModule.id);
    };

    const retryLoading = () => {
      loadTrainingContent();
    };

    // Lifecycle hooks
    onMounted(() => {
      loadTrainingContent();
    });

    return {
      ...store,
      canMoveToNextModule,
      canAccessModule,
      handleTimeUpdate,
      handleVideoComplete,
      handleQuizComplete,
      nextModule,
      previousModule,
      markCurrentModuleComplete,
      retryLoading,
    };
  },
});
</script>

<style scoped>
.training-player {
  @apply relative min-h-screen bg-white;
}

.loading-overlay {
  @apply absolute inset-0 flex flex-col items-center justify-center bg-white bg-opacity-90;
}

.spinner {
  @apply w-12 h-12 border-4 border-blue-500 border-t-transparent rounded-full animate-spin;
}

.error-message {
  @apply p-4 text-center text-red-600;
}

.retry-button {
  @apply mt-2 px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600;
}

.module-navigation {
  @apply flex flex-wrap gap-2 p-4 border-b;
}

.module-button {
  @apply px-4 py-2 rounded-lg transition-colors bg-gray-100 hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed;
}

.module-button.active {
  @apply bg-blue-500 text-white;
}

.module-content {
  @apply p-4;
}

.navigation-controls {
  @apply flex justify-between p-4 border-t;
}

.nav-button {
  @apply px-6 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 disabled:opacity-50;
}

.document-viewer {
  @apply prose max-w-none;
}

.complete-button {
  @apply mt-4 px-6 py-2 bg-green-500 text-white rounded hover:bg-green-600;
}
</style>