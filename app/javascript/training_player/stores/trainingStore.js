import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useTrainingStore = defineStore('training', () => {
  // State
  const currentModule = ref(null)
  const modules = ref([])
  const progress = ref({
    completedModules: [],
    currentPosition: 0,
    totalTime: 0,
    lastSaved: null
  })
  const isLoading = ref(false)
  const error = ref(null)

  // Getters
  const completionPercentage = computed(() => {
    if (!modules.value.length) return 0
    return Math.round((progress.value.completedModules.length / modules.value.length) * 100)
  })

  const currentModuleIndex = computed(() => {
    if (!currentModule.value || !modules.value.length) return -1
    return modules.value.findIndex(m => m.id === currentModule.value.id)
  })

  const isComplete = computed(() => {
    return completionPercentage.value === 100
  })

  // Actions
  function setModules(newModules) {
    modules.value = newModules
    if (newModules.length && !currentModule.value) {
      currentModule.value = newModules[0]
    }
  }

  function setCurrentModule(moduleId) {
    const module = modules.value.find(m => m.id === moduleId)
    if (module) {
      currentModule.value = module
    }
  }

  async function saveProgress() {
    try {
      isLoading.value = true
      const response = await fetch('/api/training/progress', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          moduleId: currentModule.value?.id,
          progress: progress.value
        })
      })

      if (!response.ok) throw new Error('Failed to save progress')

      progress.value.lastSaved = new Date()
      error.value = null
    } catch (e) {
      error.value = e.message
    } finally {
      isLoading.value = false
    }
  }

  function markModuleComplete(moduleId) {
    if (!progress.value.completedModules.includes(moduleId)) {
      progress.value.completedModules.push(moduleId)
      saveProgress()
    }
  }

  function updatePosition(position) {
    progress.value.currentPosition = position
    // Debounced save to prevent too many requests
    const debounced = setTimeout(() => {
      saveProgress()
    }, 1000)
    return () => clearTimeout(debounced)
  }

  function updateTotalTime(time) {
    progress.value.totalTime = time
  }

  return {
    // State
    currentModule,
    modules,
    progress,
    isLoading,
    error,

    // Getters
    completionPercentage,
    currentModuleIndex,
    isComplete,

    // Actions
    setModules,
    setCurrentModule,
    saveProgress,
    markModuleComplete,
    updatePosition,
    updateTotalTime
  }
})