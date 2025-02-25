<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from "vue";

const props = defineProps({
  videoUrl: {
    type: String,
    required: true,
  },
});

const emit = defineEmits(["completed"]);

const videoRef = ref(null);
const isLoading = ref(true);
const progress = ref(0);
let checkInterval = null;

const progressPercent = computed(() => {
  return `${Math.round(progress.value * 100)}%`;
});

const onTimeUpdate = () => {
  const video = videoRef.value;
  if (video && video.currentTime > 0) {
    progress.value = video.currentTime / video.duration;
    
    // Consider video completed if we're within 2 seconds of the end
    if (video.currentTime >= video.duration - 2) {
      emit("completed");
      if (checkInterval) {
        clearInterval(checkInterval);
        checkInterval = null;
      }
    }
  }
};

const onLoadedData = () => {
  isLoading.value = false;
};

onMounted(() => {
  if (videoRef.value) {
    // Check every second for completion
    checkInterval = setInterval(() => {
      onTimeUpdate();
    }, 1000);
  }
});

onBeforeUnmount(() => {
  if (checkInterval) {
    clearInterval(checkInterval);
  }
});
</script>

<template>
  <div class="video-player-container relative">
    <!-- 16:9 Aspect Ratio Container -->
    <div class="relative w-full rounded-xl overflow-hidden bg-gray-900 aspect-video">
      <!-- Loading State -->
      <div v-if="isLoading" class="absolute inset-0 flex items-center justify-center bg-gray-900 bg-opacity-50 backdrop-blur-sm">
        <div class="loading-spinner"></div>
      </div>

      <!-- Video Player -->
      <video
        ref="videoRef"
        class="w-full h-full object-cover"
        controls
        @timeupdate="onTimeUpdate"
        @loadeddata="onLoadedData"
        controlsList="nodownload"
        playsInline
      >
        <source :src="videoUrl" type="video/mp4" />
        Your browser does not support the video tag.
      </video>

      <!-- Progress Bar -->
      <div class="absolute bottom-0 left-0 w-full h-1 bg-gray-800">
        <div
          class="h-full bg-primary-500 transition-all duration-300"
          :style="{ width: progressPercent }"
        ></div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.video-player-container {
  @apply relative w-full max-w-4xl mx-auto shadow-xl;
}

/* Custom Video Controls */
:deep(video::-webkit-media-controls) {
  @apply bg-opacity-50 backdrop-blur-sm;
}

:deep(video::-webkit-media-controls-panel) {
  @apply bg-gradient-to-t from-gray-900 to-transparent;
}

:deep(video::-webkit-media-controls-play-button) {
  @apply text-primary-500;
}

:deep(video::-webkit-media-controls-timeline) {
  @apply bg-primary-500/20;
}

:deep(video::-webkit-media-controls-current-time-display),
:deep(video::-webkit-media-controls-time-remaining-display) {
  @apply text-white;
}
</style>
