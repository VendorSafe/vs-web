<template>
  <div class="video-player">
    <video
      ref="videoRef"
      class="video-element"
      :src="src"
      @timeupdate="handleTimeUpdate"
      @ended="handleVideoEnd"
      @loadedmetadata="handleMetadataLoaded"
      controls
    ></video>

    <!-- Custom Controls -->
    <div class="video-controls">
      <div class="progress-bar" @click="handleProgressBarClick">
        <div
          class="progress-track"
          :style="{ width: `${progressPercentage}%` }"
        ></div>
      </div>

      <div class="time-display">
        {{ formatTime(currentTime) }} / {{ formatTime(duration) }}
      </div>
    </div>
  </div>
</template>

<script>
import {
  defineComponent,
  ref,
  computed,
  onMounted,
  onBeforeUnmount,
} from "vue";

export default defineComponent({
  name: "VideoPlayer",

  props: {
    src: {
      type: String,
      required: true,
    },
    currentTime: {
      type: Number,
      default: 0,
    },
    autoplay: {
      type: Boolean,
      default: false,
    },
  },

  emits: ["timeupdate", "complete"],

  setup(props, { emit }) {
    const videoRef = ref(null);
    const duration = ref(0);
    const isPlaying = ref(false);
    const currentTimeRef = ref(props.currentTime);

    // Computed
    const progressPercentage = computed(() => {
      if (!duration.value) return 0;
      return (currentTimeRef.value / duration.value) * 100;
    });

    // Methods
    const formatTime = (seconds) => {
      const mins = Math.floor(seconds / 60);
      const secs = Math.floor(seconds % 60);
      return `${mins}:${secs.toString().padStart(2, "0")}`;
    };

    const handleTimeUpdate = () => {
      if (!videoRef.value) return;
      currentTimeRef.value = videoRef.value.currentTime;
      emit("timeupdate", currentTimeRef.value);
    };

    const handleVideoEnd = () => {
      emit("complete");
    };

    const handleMetadataLoaded = () => {
      if (!videoRef.value) return;
      duration.value = videoRef.value.duration;

      // Set initial time if provided
      if (props.currentTime > 0) {
        videoRef.value.currentTime = props.currentTime;
      }

      // Start playing if autoplay is enabled
      if (props.autoplay) {
        videoRef.value.play();
      }
    };

    const handleProgressBarClick = (event) => {
      if (!videoRef.value) return;

      const progressBar = event.currentTarget;
      const rect = progressBar.getBoundingClientRect();
      const clickPosition = event.clientX - rect.left;
      const percentage = clickPosition / rect.width;

      const newTime = percentage * duration.value;
      videoRef.value.currentTime = newTime;
      currentTimeRef.value = newTime;
      emit("timeupdate", newTime);
    };

    // Save progress periodically
    let progressInterval;
    onMounted(() => {
      progressInterval = setInterval(() => {
        if (isPlaying.value) {
          emit("timeupdate", currentTimeRef.value);
        }
      }, 5000); // Save every 5 seconds
    });

    onBeforeUnmount(() => {
      if (progressInterval) {
        clearInterval(progressInterval);
      }
    });

    return {
      videoRef,
      duration,
      currentTime: currentTimeRef,
      progressPercentage,
      formatTime,
      handleTimeUpdate,
      handleVideoEnd,
      handleMetadataLoaded,
      handleProgressBarClick,
    };
  },
});
</script>

<style scoped>
.video-player {
  @apply relative w-full bg-black rounded-lg overflow-hidden;
}

.video-element {
  @apply w-full aspect-video;
}

.video-controls {
  @apply absolute bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-black/50 to-transparent;
}

.progress-bar {
  @apply relative h-2 bg-gray-600 rounded cursor-pointer;
}

.progress-track {
  @apply absolute top-0 left-0 h-full bg-blue-500 rounded transition-all;
}

.time-display {
  @apply mt-2 text-sm text-white font-mono;
}
</style>