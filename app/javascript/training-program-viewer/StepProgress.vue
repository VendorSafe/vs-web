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
    "flex items-center justify-center w-8 h-8 rounded-full transition-colors duration-200";

  if (index === props.currentIndex) {
    return `${baseClasses} bg-blue-500 text-white`;
  }

  if (isStepComplete(index)) {
    return `${baseClasses} bg-green-500 text-white cursor-pointer hover:bg-green-600`;
  }

  return `${baseClasses} bg-gray-200 text-gray-500`;
};

const getConnectorClass = (index) => {
  const baseClass = "flex-1 h-1 mx-2";

  if (isStepComplete(index) && isStepComplete(index + 1)) {
    return `${baseClass} bg-green-500`;
  }

  if (isStepComplete(index)) {
    return `${baseClass} bg-blue-500`;
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
  <div class="step-progress-container">
    <div class="flex items-center justify-between mb-8">
      <div
        v-for="(content, index) in contents"
        :key="content.id"
        class="flex items-center flex-1"
      >
        <button
          :class="getStepClass(index)"
          @click="selectStep(index)"
          :disabled="!isStepComplete(index) && index !== currentIndex"
        >
          {{ index + 1 }}
        </button>

        <div
          v-if="index < contents.length - 1"
          :class="getConnectorClass(index)"
        />
      </div>
    </div>

    <div class="grid grid-cols-4 gap-4 text-sm text-center">
      <div
        v-for="(content, index) in contents"
        :key="content.id"
        class="text-gray-600"
        :class="{ 'font-medium': index === currentIndex }"
      >
        {{ content.title }}
      </div>
    </div>
  </div>
</template>

<style scoped>
.step-progress-container {
  @apply max-w-4xl mx-auto py-6;
}
</style>
