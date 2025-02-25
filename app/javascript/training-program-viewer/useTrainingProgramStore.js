import { defineStore } from 'pinia';
import axios from 'axios';

export const useTrainingProgramStore = defineStore('trainingProgram', {
  state: () => ({
    trainingProgram: null,
    isLoading: false,
    error: null,
    currentContentIndex: 0,
    certificate: null,
    certificateLoading: false,
    certificateError: null,
    offlineMode: false,
    cachedData: {}
  }),

  getters: {
    currentContent: (state) =>
      state.trainingProgram?.training_contents?.[state.currentContentIndex] || null,

    progress: (state) =>
      state.trainingProgram?.progress || {},

    isComplete: (state) => {
      if (!state.trainingProgram?.training_contents) return false;
      const totalContents = state.trainingProgram.training_contents.length;
      const completedContents = Object.values(state.progress).filter(p => p.completed).length;
      return totalContents === completedContents;
    },

    completionPercentage: (state) => {
      if (!state.trainingProgram?.training_contents) return 0;
      const totalContents = state.trainingProgram.training_contents.length;
      if (totalContents === 0) return 0;
      
      const completedContents = Object.values(state.progress).filter(p => p.completed).length;
      return Math.round((completedContents / totalContents) * 100);
    },

    hasCertificate: (state) => {
      return state.certificate !== null;
    }
  },

  actions: {
    async fetchTrainingProgram(id) {
      this.isLoading = true;
      this.error = null;
      
      // Check if we're offline and have cached data
      if (this.offlineMode && this.cachedData[id]) {
        this.trainingProgram = this.cachedData[id];
        this.isLoading = false;
        return;
      }
      
      try {
        const response = await axios.get(`/api/v1/training_programs/${id}`);
        this.trainingProgram = response.data;
        
        // Cache the data for offline use
        this.cachedData[id] = response.data;
        
        // Store in localStorage for persistent offline access
        try {
          localStorage.setItem(`training_program_${id}`, JSON.stringify(response.data));
        } catch (e) {
          console.warn('Failed to cache training program in localStorage:', e);
        }
      } catch (error) {
        // If offline, try to load from localStorage
        if (!navigator.onLine) {
          this.offlineMode = true;
          try {
            const cachedData = localStorage.getItem(`training_program_${id}`);
            if (cachedData) {
              this.trainingProgram = JSON.parse(cachedData);
              this.cachedData[id] = this.trainingProgram;
              this.isLoading = false;
              return;
            }
          } catch (e) {
            console.warn('Failed to load cached training program:', e);
          }
        }
        
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

        // If offline, just update local state
        if (this.offlineMode) {
          this.trainingProgram = {
            ...this.trainingProgram,
            progress: updatedProgress
          };
          
          // Store pending updates for sync when online
          try {
            const pendingUpdates = JSON.parse(localStorage.getItem('pending_progress_updates') || '[]');
            pendingUpdates.push({
              programId: this.trainingProgram.id,
              contentId,
              progressData,
              timestamp: new Date().toISOString()
            });
            localStorage.setItem('pending_progress_updates', JSON.stringify(pendingUpdates));
          } catch (e) {
            console.warn('Failed to store pending update:', e);
          }
          
          return;
        }

        await axios.put(
          `/api/v1/training_programs/${this.trainingProgram.id}/update_progress`,
          { progress: updatedProgress }
        );

        this.trainingProgram = {
          ...this.trainingProgram,
          progress: updatedProgress
        };
        
        // Update cached data
        if (this.cachedData[this.trainingProgram.id]) {
          this.cachedData[this.trainingProgram.id] = {
            ...this.cachedData[this.trainingProgram.id],
            progress: updatedProgress
          };
          
          try {
            localStorage.setItem(
              `training_program_${this.trainingProgram.id}`,
              JSON.stringify(this.cachedData[this.trainingProgram.id])
            );
          } catch (e) {
            console.warn('Failed to update cached training program:', e);
          }
        }
        
        // Check if program is complete and fetch certificate if needed
        if (this.isComplete && !this.certificate) {
          this.fetchCertificate();
        }
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to update progress';
        throw error;
      }
    },

    async fetchCertificate() {
      if (!this.trainingProgram) return;
      
      this.certificateLoading = true;
      this.certificateError = null;
      
      try {
        const response = await axios.get(`/api/v1/training_programs/${this.trainingProgram.id}/certificate`);
        this.certificate = response.data;
        
        // Cache certificate data
        try {
          localStorage.setItem(
            `certificate_${this.trainingProgram.id}`,
            JSON.stringify(response.data)
          );
        } catch (e) {
          console.warn('Failed to cache certificate:', e);
        }
      } catch (error) {
        this.certificateError = error.response?.data?.error || 'Failed to fetch certificate';
        
        // If 404, it means no certificate exists yet
        if (error.response?.status === 404) {
          this.certificate = null;
        }
      } finally {
        this.certificateLoading = false;
      }
    },

    async generateCertificate() {
      if (!this.trainingProgram || !this.isComplete) return;
      
      this.certificateLoading = true;
      this.certificateError = null;
      
      try {
        const response = await axios.post(
          `/api/v1/training_programs/${this.trainingProgram.id}/generate_certificate`
        );
        this.certificate = response.data;
      } catch (error) {
        this.certificateError = error.response?.data?.error || 'Failed to generate certificate';
      } finally {
        this.certificateLoading = false;
      }
    },

    setCurrentContentIndex(index) {
      if (index >= 0 && index < this.trainingProgram?.training_contents?.length) {
        this.currentContentIndex = index;
      }
    },

    nextContent() {
      this.setCurrentContentIndex(this.currentContentIndex + 1);
    },
    
    // Offline mode management
    setOfflineMode(value) {
      this.offlineMode = value;
    },
    
    async syncPendingUpdates() {
      if (this.offlineMode || !navigator.onLine) return;
      
      try {
        const pendingUpdates = JSON.parse(localStorage.getItem('pending_progress_updates') || '[]');
        if (pendingUpdates.length === 0) return;
        
        // Group updates by program ID
        const updatesByProgram = {};
        pendingUpdates.forEach(update => {
          if (!updatesByProgram[update.programId]) {
            updatesByProgram[update.programId] = {
              programId: update.programId,
              updates: {}
            };
          }
          
          // Keep only the latest update for each content
          updatesByProgram[update.programId].updates[update.contentId] = update.progressData;
        });
        
        // Send updates for each program
        for (const programId in updatesByProgram) {
          const programUpdates = updatesByProgram[programId];
          await axios.put(
            `/api/v1/training_programs/${programId}/update_progress`,
            { progress: programUpdates.updates }
          );
        }
        
        // Clear pending updates
        localStorage.removeItem('pending_progress_updates');
      } catch (error) {
        console.error('Failed to sync pending updates:', error);
      }
    }
  }
});
