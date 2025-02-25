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
  if (!selected || selected.answer !== answer) return "border-gray-200";

  return selected.isCorrect
    ? "bg-primary-50 border-primary-500 text-primary-700"
    : "bg-red-50 border-red-500 text-red-700";
};
</script>

<template>
  <div v-if="currentQuestion" class="questions-panel card fade-in">
    <div class="card-body">
      <h3 class="text-2xl font-bold mb-4 text-secondary-800">{{ currentQuestion.title }}</h3>
      <p class="mb-8 text-gray-600">{{ currentQuestion.body }}</p>

      <div class="space-y-4">
        <button
          v-for="answer in allAnswers"
          :key="answer"
          class="w-full p-4 text-left rounded-xl transition-all duration-200 border-2 hover:shadow-md"
          :class="[
            hasAnswered ? getAnswerClass(answer) : 'hover:border-primary-500 hover:bg-primary-50',
            'focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2'
          ]"
          @click="!hasAnswered && checkAnswer(answer)"
          :disabled="hasAnswered"
        >
          {{ answer }}
        </button>
      </div>

      <div v-if="hasAnswered" class="mt-8 p-4 rounded-lg text-center">
        <div
          v-if="selectedAnswers[currentQuestionIndex].isCorrect"
          class="flex items-center justify-center space-x-2 text-green-600"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
          <span class="font-medium">Correct! Great job!</span>
        </div>
        <div
          v-else
          class="flex items-center justify-center space-x-2 text-red-600"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
          <span class="font-medium">Incorrect. Please try again.</span>
        </div>
      </div>

      <p v-if="errorMessage" class="mt-4 p-4 bg-red-50 text-red-600 rounded-lg">{{ errorMessage }}</p>
    </div>
  </div>
</template>

<style scoped>
.questions-panel {
  @apply max-w-2xl mx-auto;
}
</style>
