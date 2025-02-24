<script setup>
import { ref, computed } from "vue";

const props = defineProps({
  questions: {
    type: Array,
    required: true,
    default: () => [],
  },
  currentQuestionIndex: {
    type: Number,
    default: 0,
  },
});

const emit = defineEmits(["completed", "answer-selected"]);

const selectedAnswers = ref({});
const errorMessage = ref("");

const currentQuestion = computed(
  () => props.questions[props.currentQuestionIndex] || null
);

const isLastQuestion = computed(
  () => props.currentQuestionIndex === props.questions.length - 1
);

const hasAnswered = computed(
  () => selectedAnswers.value[props.currentQuestionIndex] !== undefined
);

function shuffleArray(array) {
  // Create a copy of the array to avoid mutating props
  const shuffled = [...array];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled;
}

const allAnswers = computed(() => {
  if (!currentQuestion.value) return [];
  const goodAnswers = currentQuestion.value.good_answers?.split("\n") || [];
  const badAnswers = currentQuestion.value.bad_answers?.split("\n") || [];
  return shuffleArray([...goodAnswers, ...badAnswers]);
});

const checkAnswer = (answer) => {
  const goodAnswers = currentQuestion.value.good_answers?.split("\n") || [];
  const isCorrect = goodAnswers.includes(answer);

  selectedAnswers.value[props.currentQuestionIndex] = {
    answer,
    isCorrect,
  };

  emit("answer-selected", {
    questionIndex: props.currentQuestionIndex,
    answer,
    isCorrect,
  });

  if (isCorrect && isLastQuestion.value) {
    emit("completed");
  }
};

const getAnswerClass = (answer) => {
  const selected = selectedAnswers.value[props.currentQuestionIndex];
  if (!selected || selected.answer !== answer) return "";

  return selected.isCorrect
    ? "bg-green-100 border-green-500"
    : "bg-red-100 border-red-500";
};
</script>

<template>
  <div
    v-if="currentQuestion"
    class="questions-panel p-6 bg-white rounded-lg shadow-lg"
  >
    <h3 class="text-xl font-bold mb-4">{{ currentQuestion.title }}</h3>
    <p class="mb-6 text-gray-700">{{ currentQuestion.body }}</p>

    <div class="space-y-3">
      <button
        v-for="answer in allAnswers"
        :key="answer"
        class="w-full p-4 text-left border-2 rounded-lg transition-colors duration-200 hover:bg-gray-50"
        :class="getAnswerClass(answer)"
        @click="!hasAnswered && checkAnswer(answer)"
        :disabled="hasAnswered"
      >
        {{ answer }}
      </button>
    </div>

    <div v-if="hasAnswered" class="mt-6">
      <p
        v-if="selectedAnswers[currentQuestionIndex].isCorrect"
        class="text-green-600 font-medium"
      >
        Correct! Great job!
      </p>
      <p v-else class="text-red-600 font-medium">
        Incorrect. Please try again.
      </p>
    </div>

    <p v-if="errorMessage" class="mt-4 text-red-600">{{ errorMessage }}</p>
  </div>
</template>

<style scoped>
.questions-panel {
  @apply max-w-2xl mx-auto;
}
</style>
