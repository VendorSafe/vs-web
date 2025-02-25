<script setup>
import { computed } from "vue";

const props = defineProps({
  contents: {
    type: Array,
    required: true,
  },
  currentIndex: {
    type: Number,
    required: true,
  },
  progress: {
    type: Object,
    required: true,
    default: () => ({}),
  },
});

const emit = defineEmits(["step-selected"]);

const isStepComplete = (index) => {
  const content = props.contents[index];
  return content && props.progress[content.id];
};

const getStepClass = (index) => {
  const baseClasses =
    "flex items-center justify-center w-10 h-10 rounded-full transition-all duration-300 transform hover:scale-110";

  if (index === props.currentIndex) {
    return `${baseClasses} bg-primary-500 text-white shadow-lg ring-4 ring-primary-100`;
  }

  if (isStepComplete(index)) {
    return `${baseClasses} bg-secondary-500 text-white cursor-pointer hover:bg-secondary-600 shadow-md`;
  }

  return `${baseClasses} bg-gray-100 text-gray-400 border-2 border-gray-200`;
};

const getConnectorClass = (index) => {
  const baseClass = "flex-1 h-1 mx-4 transition-all duration-300";

  if (isStepComplete(index) && isStepComplete(index + 1)) {
    return `${baseClass} bg-secondary-500`;
  }

  if (isStepComplete(index)) {
    return `${baseClass} bg-primary-500`;
  }

  return `${baseClass} bg-gray-200`;
};

const selectStep = (index) => {
  if (isStepComplete(index)) {
    emit("step-selected", index);
  }
};
</script>

<template>
  <div class="step-progress-container card card-body">
    <div class="relative">
      <div class="flex items-center justify-between mb-8">
        <div
          v-for="(content, index) in contents"
          :key="content.id"
          class="flex items-center flex-1"
        >
          <div class="relative group">
            <button
              :class="getStepClass(index)"
              @click="selectStep(index)"
              :disabled="!isStepComplete(index) && index !== currentIndex"
            >
              <span v-if="isStepComplete(index)" class="text-lg">✓</span>
              <span v-else>{{ index + 1 }}</span>
            </button>
            <div class="absolute -bottom-12 left-1/2 transform -translate-x-1/2 opacity-0 group-hover:opacity-100 transition-opacity duration-200">
              <div class="bg-gray-900 text-white text-xs px-2 py-1 rounded whitespace-nowrap">
                {{ isStepComplete(index) ? 'Completed' : index === currentIndex ? 'Current' : 'Locked' }}
              </div>
            </div>
          </div>

          <div
            v-if="index < contents.length - 1"
            :class="getConnectorClass(index)"
          />
        </div>
      </div>
    </div>

    <div class="grid grid-cols-4 gap-6 text-sm">
      <div
        v-for="(content, index) in contents"
        :key="content.id"
        class="text-center transition-all duration-300"
        :class="{
          'text-secondary-800 font-medium transform scale-105': index === currentIndex,
          'text-secondary-600': isStepComplete(index),
          'text-gray-400': !isStepComplete(index) && index !== currentIndex
        }"
      >
        <div class="line-clamp-2">{{ content.title }}</div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.step-progress-container {
  @apply max-w-4xl mx-auto py-6;
}
</style>
