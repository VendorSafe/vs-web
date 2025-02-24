// Training Player Entrypoint
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import TrainingPlayer from '../training_player/components/TrainingPlayer.vue'
import VideoPlayer from '../training_player/components/VideoPlayer.vue'
import QuestionList from '../training_player/components/QuestionList.vue'
import ProgressBar from '../training_player/components/ProgressBar.vue'

// Initialize Pinia store
const pinia = createPinia()

// Create Vue application
const app = createApp({
  data() {
    return {
      programId: null
    }
  },
  mounted() {
    // Get program ID from data attribute
    const playerElement = document.getElementById('training-player')
    if (playerElement) {
      this.programId = playerElement.dataset.programId
    }
  },
  render() {
    return this.programId ? h(TrainingPlayer, { programId: this.programId }) : null
  }
})

// Register components
app.component('VideoPlayer', VideoPlayer)
app.component('QuestionList', QuestionList)
app.component('ProgressBar', ProgressBar)

// Use Pinia
app.use(pinia)

// Mount when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  const el = document.querySelector('#training-player')
  if (el) {
    app.mount(el)
  }
})