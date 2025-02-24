<template>
  <div class="progress-container">
    <div class="progress-info">
      <span class="module-count"
        >Module {{ currentModule }} of {{ totalModules }}</span
      >
      <span class="percentage">{{ percentage }}% Complete</span>
    </div>
    <div class="progress-track">
      <div
        class="progress-bar"
        :style="{ width: `${percentage}%` }"
        :class="{ complete: isComplete }"
      ></div>
      <div class="progress-markers">
        <div
          v-for="n in totalModules"
          :key="n"
          class="marker"
          :class="{
            complete: n <= completedModules,
            current: n === currentModule,
            locked: n > currentModule && !isModuleAccessible(n),
          }"
          :style="{ left: `${((n - 1) / (totalModules - 1)) * 100}%` }"
        >
          <div class="marker-tooltip">
            Module {{ n }}
            <span v-if="n <= completedModules">✓</span>
            <span v-else-if="n === currentModule">Current</span>
            <span v-else-if="!isModuleAccessible(n)">🔒</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { defineComponent, computed } from "vue";

export default defineComponent({
  name: "ProgressBar",

  props: {
    currentModule: {
      type: Number,
      required: true,
    },
    totalModules: {
      type: Number,
      required: true,
    },
    percentage: {
      type: Number,
      required: true,
    },
    completedModules: {
      type: Number,
      default: 0,
    },
  },

  setup(props) {
    const isComplete = computed(() => props.percentage === 100);

    const isModuleAccessible = (moduleNumber) => {
      return (
        moduleNumber <= props.currentModule + 1 &&
        props.completedModules >= moduleNumber - 1
      );
    };

    return {
      isComplete,
      isModuleAccessible,
    };
  },
});
</script>

<style scoped>
.progress-container {
  @apply w-full mb-6;
}

.progress-info {
  @apply flex justify-between mb-2 text-sm text-gray-600;
}

.progress-track {
  @apply relative h-2 bg-gray-200 rounded-full;
}

.progress-bar {
  @apply absolute top-0 left-0 h-full bg-blue-500 rounded-full transition-all duration-300;
}

.progress-bar.complete {
  @apply bg-green-500;
}

.progress-markers {
  @apply absolute top-0 left-0 w-full h-full;
}

.marker {
  @apply absolute top-1/2 w-4 h-4 -mt-2 -ml-2 rounded-full border-2 border-white bg-gray-300 transition-all duration-300;
}

.marker.complete {
  @apply bg-green-500;
}

.marker.current {
  @apply bg-blue-500 ring-4 ring-blue-200;
}

.marker.locked {
  @apply bg-gray-400;
}

.marker-tooltip {
  @apply absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-2 py-1 text-xs text-white bg-gray-800 rounded whitespace-nowrap opacity-0 transition-opacity duration-200;
}

.marker:hover .marker-tooltip {
  @apply opacity-100;
}
</style>