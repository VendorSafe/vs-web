<template>
  <div class="question-list">
    <!-- Quiz Header -->
    <div class="quiz-header">
      <h2 class="quiz-title">{{ title || "Assessment" }}</h2>
      <p class="quiz-description" v-if="description">
        {{ description }}
      </p>
    </div>

    <!-- Questions -->
    <div class="questions" v-if="!isComplete">
      <div
        v-for="(question, index) in questions"
        :key="question.id"
        class="question-card"
      >
        <h3 class="question-title">
          Question {{ index + 1 }}: {{ question.title }}
        </h3>

        <p class="question-body">{{ question.body }}</p>

        <!-- Multiple Choice -->
        <div v-if="question.type === 'multiple_choice'" class="answer-options">
          <label
            v-for="option in shuffledOptions(question)"
            :key="option.id"
            class="answer-option"
          >
            <input
              type="radio"
              :name="`question-${question.id}`"
              :value="option.id"
              v-model="answers[question.id]"
              :disabled="isSubmitted"
            />
            <span class="option-text">{{ option.text }}</span>
          </label>
        </div>

        <!-- True/False -->
        <div v-else-if="question.type === 'true_false'" class="answer-options">
          <label class="answer-option">
            <input
              type="radio"
              :name="`question-${question.id}`"
              :value="true"
              v-model="answers[question.id]"
              :disabled="isSubmitted"
            />
            <span class="option-text">True</span>
          </label>
          <label class="answer-option">
            <input
              type="radio"
              :name="`question-${question.id}`"
              :value="false"
              v-model="answers[question.id]"
              :disabled="isSubmitted"
            />
            <span class="option-text">False</span>
          </label>
        </div>

        <!-- Feedback -->
        <div v-if="isSubmitted" class="feedback">
          <p :class="['feedback-text', getFeedbackClass(question.id)]">
            {{ getFeedbackText(question.id) }}
          </p>
        </div>
      </div>

      <!-- Submit Button -->
      <div class="submit-section">
        <button
          @click="submitQuiz"
          :disabled="!canSubmit || isSubmitted"
          class="submit-button"
        >
          {{ isSubmitted ? "Submitted" : "Submit Answers" }}
        </button>
      </div>
    </div>

    <!-- Results -->
    <div v-else class="quiz-results">
      <h3 class="results-title">Quiz Complete!</h3>
      <div class="score-display">
        <p class="score-text">Your Score: {{ score }}%</p>
        <p
          :class="[
            'result-message',
            isPassing ? 'text-green-600' : 'text-red-600',
          ]"
        >
          {{ isPassing ? "Congratulations! You passed!" : "Please try again." }}
        </p>
      </div>
      <button v-if="!isPassing" @click="resetQuiz" class="retry-button">
        Retry Quiz
      </button>
    </div>
  </div>
</template>

<script>
import { defineComponent, ref, computed } from "vue";

export default defineComponent({
  name: "QuestionList",

  props: {
    title: {
      type: String,
      default: "",
    },
    description: {
      type: String,
      default: "",
    },
    questions: {
      type: Array,
      required: true,
      validator: (questions) =>
        questions.every(
          (q) =>
            q.id &&
            q.title &&
            q.body &&
            (q.type === "multiple_choice" || q.type === "true_false")
        ),
    },
    passingScore: {
      type: Number,
      default: 70,
    },
  },

  emits: ["complete"],

  setup(props, { emit }) {
    const answers = ref({});
    const isSubmitted = ref(false);
    const isComplete = ref(false);
    const score = ref(0);

    // Computed
    const canSubmit = computed(() => {
      return props.questions.every((q) => answers.value[q.id] !== undefined);
    });

    const isPassing = computed(() => {
      return score.value >= props.passingScore;
    });

    // Methods
    const shuffledOptions = (question) => {
      if (!question.options) return [];
      return [...question.options].sort(() => Math.random() - 0.5);
    };

    const calculateScore = () => {
      const totalQuestions = props.questions.length;
      const correctAnswers = props.questions.filter((q) => {
        const answer = answers.value[q.id];
        return q.type === "multiple_choice"
          ? answer === q.correctOption
          : answer === q.correctAnswer;
      }).length;

      return Math.round((correctAnswers / totalQuestions) * 100);
    };

    const getFeedbackClass = (questionId) => {
      const question = props.questions.find((q) => q.id === questionId);
      const isCorrect =
        question.type === "multiple_choice"
          ? answers.value[questionId] === question.correctOption
          : answers.value[questionId] === question.correctAnswer;

      return isCorrect ? "text-green-600" : "text-red-600";
    };

    const getFeedbackText = (questionId) => {
      const question = props.questions.find((q) => q.id === questionId);
      const isCorrect =
        question.type === "multiple_choice"
          ? answers.value[questionId] === question.correctOption
          : answers.value[questionId] === question.correctAnswer;

      return isCorrect
        ? "Correct!"
        : `Incorrect. The correct answer was: ${
            question.type === "multiple_choice"
              ? question.options.find((o) => o.id === question.correctOption)
                  .text
              : question.correctAnswer
              ? "True"
              : "False"
          }`;
    };

    const submitQuiz = () => {
      isSubmitted.value = true;
      score.value = calculateScore();

      if (isPassing.value) {
        setTimeout(() => {
          isComplete.value = true;
          emit("complete", score.value);
        }, 3000);
      }
    };

    const resetQuiz = () => {
      answers.value = {};
      isSubmitted.value = false;
      score.value = 0;
    };

    return {
      answers,
      isSubmitted,
      isComplete,
      score,
      canSubmit,
      isPassing,
      shuffledOptions,
      getFeedbackClass,
      getFeedbackText,
      submitQuiz,
      resetQuiz,
    };
  },
});
</script>

<style scoped>
.question-list {
  @apply max-w-3xl mx-auto p-6;
}

.quiz-header {
  @apply mb-8 text-center;
}

.quiz-title {
  @apply text-2xl font-bold mb-2;
}

.quiz-description {
  @apply text-gray-600;
}

.question-card {
  @apply bg-white rounded-lg shadow-md p-6 mb-6;
}

.question-title {
  @apply text-lg font-semibold mb-2;
}

.question-body {
  @apply text-gray-700 mb-4;
}

.answer-options {
  @apply space-y-3;
}

.answer-option {
  @apply flex items-center space-x-3 p-3 rounded-lg border hover:bg-gray-50 cursor-pointer;
}

.answer-option input[type="radio"] {
  @apply w-4 h-4 text-blue-600;
}

.option-text {
  @apply text-gray-700;
}

.feedback {
  @apply mt-4 p-3 rounded-lg bg-gray-50;
}

.submit-section {
  @apply mt-8 text-center;
}

.submit-button {
  @apply px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed;
}

.quiz-results {
  @apply text-center p-8 bg-white rounded-lg shadow-md;
}

.results-title {
  @apply text-2xl font-bold mb-4;
}

.score-display {
  @apply space-y-2 mb-6;
}

.score-text {
  @apply text-xl font-semibold;
}

.retry-button {
  @apply px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600;
}
</style>