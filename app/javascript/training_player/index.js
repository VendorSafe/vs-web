// Training Program Player Entry Point
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import TrainingPlayer from './components/TrainingPlayer.vue'
import VideoPlayer from './components/VideoPlayer.vue'
import QuestionList from './components/QuestionList.vue'
import ProgressBar from './components/ProgressBar.vue'

// Register components globally
const app = createApp({})
const pinia = createPinia()

app.use(pinia)

app.component('TrainingPlayer', TrainingPlayer)
app.component('VideoPlayer', VideoPlayer)
app.component('QuestionList', QuestionList)
app.component('ProgressBar', ProgressBar)

// Mount when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  const el = document.querySelector('#training-player')
  if (el) {
    app.mount(el)
  }
})