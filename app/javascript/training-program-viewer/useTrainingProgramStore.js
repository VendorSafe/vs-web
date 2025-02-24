import { defineStore } from 'pinia';
import axios from 'axios';

export const useTrainingProgramStore = defineStore('trainingProgram', {
  state: () => ({
    trainingProgram: null,
    isLoading: false,
    error: null,
    currentContentIndex: 0
  }),

  getters: {
    currentContent: (state) =>
      state.trainingProgram?.training_contents?.[state.currentContentIndex] || null,

    progress: (state) =>
      state.trainingProgram?.progress || {},

    isComplete: (state) => {
      if (!state.trainingProgram?.training_contents) return false;
      const totalContents = state.trainingProgram.training_contents.length;
      const completedContents = Object.keys(state.progress).length;
      return totalContents === completedContents;
    }
  },

  actions: {
    async fetchTrainingProgram(id) {
      this.isLoading = true;
      this.error = null;
      try {
        const response = await axios.get(`/api/v1/training_programs/${id}`);
        this.trainingProgram = response.data;
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to fetch training program';
      } finally {
        this.isLoading = false;
      }
    },

    async updateProgress(contentId, progressData) {
      try {
        const updatedProgress = {
          ...this.progress,
          [contentId]: progressData
        };

        await axios.put(
          `/api/v1/training_programs/${this.trainingProgram.id}/update_progress`,
          { progress: updatedProgress }
        );

        this.trainingProgram = {
          ...this.trainingProgram,
          progress: updatedProgress
        };
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to update progress';
        throw error;
      }
    },

    setCurrentContentIndex(index) {
      if (index >= 0 && index < this.trainingProgram?.training_contents?.length) {
        this.currentContentIndex = index;
      }
    },

    nextContent() {
      this.setCurrentContentIndex(this.currentContentIndex + 1);
    }
  }
});
