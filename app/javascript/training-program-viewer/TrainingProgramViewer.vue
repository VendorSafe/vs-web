<script setup>
import { onMounted, computed } from "vue";
import { useTrainingProgramStore } from "./useTrainingProgramStore";
import VideoPlayer from "./VideoPlayer.vue";
import QuestionsPanel from "./QuestionsPanel.vue";
import StepProgress from "./StepProgress.vue";

const props = defineProps({
  programId: {
    type: String,
    required: true,
  },
});

const store = useTrainingProgramStore();

const currentContent = computed(() => store.currentContent);
const isLoading = computed(() => store.isLoading);
const error = computed(() => store.error);
const trainingProgram = computed(() => store.trainingProgram);

const isVideoContent = computed(
  () => currentContent.value?.content_type === "video"
);

const currentQuestions = computed(
  () => currentContent.value?.training_questions || []
);

onMounted(async () => {
  await store.fetchTrainingProgram(props.programId);
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
</script>

<template>
  <div class="training-program-viewer bg-gradient-light min-h-screen">
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
      <StepProgress
        :contents="trainingProgram.training_contents"
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
</template>

<style scoped>
.training-program-viewer {
  @apply container mx-auto px-6 py-12;
}

.content-container {
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

:deep(.btn) {
  @apply inline-flex items-center justify-center px-6 py-3 rounded-full font-medium transition-all duration-200;
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
</style>
