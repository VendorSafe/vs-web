<script setup>
import { ref, onMounted, onBeforeUnmount } from "vue";

const props = defineProps({
  videoUrl: {
    type: String,
    required: true,
  },
});

const emit = defineEmits(["completed"]);

const videoRef = ref(null);
let checkInterval = null;

const onTimeUpdate = () => {
  const video = videoRef.value;
  if (video && video.currentTime > 0) {
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
  <div class="video-player-container">
    <video
      ref="videoRef"
      class="w-full rounded-lg shadow-lg"
      controls
      @timeupdate="onTimeUpdate"
    >
      <source :src="videoUrl" type="video/mp4" />
      Your browser does not support the video tag.
    </video>
  </div>
</template>

<style scoped>
.video-player-container {
  @apply relative w-full max-w-4xl mx-auto;
}
</style>
