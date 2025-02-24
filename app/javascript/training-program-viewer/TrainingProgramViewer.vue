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
  <div class="training-program-viewer">
    <div v-if="isLoading" class="text-center py-8">
      <div
        class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"
      ></div>
      <p class="mt-2 text-gray-600">Loading training program...</p>
    </div>

    <div v-else-if="error" class="text-center py-8">
      <p class="text-red-500">{{ error }}</p>
    </div>

    <div v-else-if="trainingProgram" class="space-y-8">
      <StepProgress
        :contents="trainingProgram.training_contents"
        :current-index="store.currentContentIndex"
        :progress="trainingProgram.progress"
        @step-selected="handleStepSelected"
      />

      <div v-if="currentContent" class="content-container">
        <h2 class="text-2xl font-bold mb-6 text-center">
          {{ currentContent.title }}
        </h2>

        <div v-if="isVideoContent">
          <VideoPlayer
            :video-url="currentContent.body"
            @completed="handleVideoComplete"
          />
        </div>

        <div v-else class="prose max-w-none mb-8">
          <div v-html="currentContent.body"></div>
        </div>

        <QuestionsPanel
          v-if="currentQuestions.length > 0"
          :questions="currentQuestions"
          @completed="handleQuestionsComplete"
        />
      </div>
    </div>
  </div>
</template>

<style scoped>
.training-program-viewer {
  @apply container mx-auto px-4 py-8;
}

.content-container {
  @apply max-w-4xl mx-auto bg-white rounded-lg shadow-lg p-8;
}
</style>
