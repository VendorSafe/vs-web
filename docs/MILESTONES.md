# Training Program Player w/ Vue.js

This guide details the custom enhancements needed to integrate a Training Program Viewer into your Bullet Train Rails application. Built on top of Bullet Train's out-of-the-box authentication, API, and asset configuration, the following steps focus on the VendorSafe application's unique requirements.

---

## Overall Steps

1. **Backend Enhancements (Rails)**
   - Add custom actions for retrieving and updating training progress
   - Extend existing models/migrations as needed
   - Implement role-based access controls
   - Add certificate generation integration

2. **Frontend Enhancements (Vue.js)**
   - Create training program viewer in `app/javascript/training-program-viewer`
   - Leverage Tailwind CSS, Vue, and Pinia stores
   - Implement role-specific UI components
   - Add certificate viewing/downloading

3. **API Integration**
   - Use Bullet Train's built-in API patterns
   - Implement role-based endpoint access
   - Add progress tracking endpoints
   - Add certificate endpoints

4. **Component Implementation**
   - Build core components:
     - VideoPlayer: Video content with progress tracking
     - QuestionsPanel: Interactive quiz system
     - StepProgress: Sequential progression tracking
     - CertificateViewer: Certificate management

5. **Progress Management**
   - Track content-specific progress
   - Implement sequential progression
   - Handle quiz submissions
   - Manage certificate generation

6. **Integration and Testing**
   - Implement comprehensive test suite
   - Test role-specific access
   - Verify progress tracking
   - Validate certificate generation

---

## Step 1: Backend Enhancements (Rails)

### 1.1 Custom Controller Actions

Add role-aware training progress logic in `app/controllers/api/v1/training_programs_controller.rb`:

```ruby
before_action :authenticate_user!
before_action :authorize_training_access!

def show
  training_membership = current_user.training_memberships.find_by(training_program: @training_program)
  progress_data = training_membership&.progress || {}
  
  render json: @training_program.as_json(
    include: [:training_contents, training_contents: [:training_questions]],
    methods: [:certificate_status]
  ).merge(
    progress: progress_data,
    role_capabilities: current_user_capabilities
  )
end

def update_progress
  training_membership = current_user.training_memberships.find_by(training_program: @training_program)
  if training_membership&.can_update_progress?
    training_membership.update_progress(params[:progress])
    head :ok
  else
    render json: { error: 'Unauthorized or invalid membership' }, status: :unauthorized
  end
end

private

def authorize_training_access!
  unless current_user.can_access_training?(@training_program)
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end

def current_user_capabilities
  {
    can_edit: current_user.can_edit_training?(@training_program),
    can_invite: current_user.can_invite_to_training?(@training_program),
    can_generate_certificate: current_user.can_generate_certificate?(@training_program)
  }
end
```

### 1.2 Progress Tracking Schema

The progress tracking schema is already implemented in `db/schema.rb`:

```ruby
create_table "training_progress", force: :cascade do |t|
  t.bigint "membership_id", null: false
  t.bigint "training_program_id", null: false
  t.bigint "training_content_id", null: false
  t.string "status", default: "not_started", null: false
  t.integer "score"
  t.integer "time_spent", default: 0
  t.datetime "last_accessed_at"
  t.timestamps
  t.index ["membership_id", "training_program_id", "training_content_id"],
    name: "idx_training_progress_unique_membership_program_content",
    unique: true
end
```

### 1.3 API Routes

Configure role-aware API routes in `config/routes.rb`:

```ruby
namespace :api do
  namespace :v1 do
    resources :training_programs, only: [:show] do
      member do
        put :update_progress
        post :submit_quiz
        get :generate_certificate
      end
    end
  end
end
```

---

## Step 2: Frontend Enhancements (Vue.js)

### 2.1 Project Structure

```
app/javascript/training-program-viewer/
├── components/
│   ├── VideoPlayer.vue
│   ├── QuestionsPanel.vue
│   ├── StepProgress.vue
│   └── CertificateViewer.vue
├── stores/
│   ├── useTrainingProgramStore.js
│   ├── useProgressStore.js
│   └── useCertificateStore.js
└── TrainingProgramViewer.vue
```

### 2.2 Pinia Stores

Example training program store with role capabilities:

```js
// stores/useTrainingProgramStore.js
import { defineStore } from 'pinia';
import axios from 'axios';

export const useTrainingProgramStore = defineStore('trainingProgram', {
  state: () => ({
    trainingProgram: null,
    isLoading: false,
    error: null,
    capabilities: {
      canEdit: false,
      canInvite: false,
      canGenerateCertificate: false
    }
  }),
  
  actions: {
    async fetchTrainingProgram(id) {
      this.isLoading = true;
      try {
        const response = await axios.get(`/api/v1/training_programs/${id}`);
        this.trainingProgram = response.data;
        this.capabilities = response.data.role_capabilities;
      } catch (error) {
        this.error = error;
      } finally {
        this.isLoading = false;
      }
    },

    async updateProgress(progressData) {
      try {
        await axios.put(
          `/api/v1/training_programs/${this.trainingProgram.id}/update_progress`,
          { progress: progressData }
        );
      } catch (error) {
        this.error = error;
      }
    },

    async generateCertificate() {
      if (!this.capabilities.canGenerateCertificate) return;
      try {
        const response = await axios.get(
          `/api/v1/training_programs/${this.trainingProgram.id}/generate_certificate`
        );
        return response.data;
      } catch (error) {
        this.error = error;
      }
    }
  }
});
```

### 2.3 Main Component

```vue
<!-- TrainingProgramViewer.vue -->
<template>
  <div v-if="trainingProgram">
    <StepProgress
      :contents="trainingProgram.training_contents"
      :current-progress="progress"
    />
    
    <component
      :is="currentContentComponent"
      :content="currentContent"
      @progress-update="handleProgressUpdate"
      @complete="handleContentComplete"
    />

    <CertificateViewer
      v-if="capabilities.canGenerateCertificate"
      :training-program="trainingProgram"
      @generate="generateCertificate"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { useTrainingProgramStore } from './stores/useTrainingProgramStore';
import VideoPlayer from './components/VideoPlayer.vue';
import QuestionsPanel from './components/QuestionsPanel.vue';
import StepProgress from './components/StepProgress.vue';
import CertificateViewer from './components/CertificateViewer.vue';

const store = useTrainingProgramStore();
const currentContent = ref(null);

const currentContentComponent = computed(() => {
  if (!currentContent.value) return null;
  switch (currentContent.value.content_type) {
    case 'video': return VideoPlayer;
    case 'quiz': return QuestionsPanel;
    default: return null;
  }
});

onMounted(async () => {
  await store.fetchTrainingProgram(props.programId);
});
</script>
```

---

## Step 3: Testing Strategy

### Unit Tests

```ruby
# test/models/training_program_test.rb
class TrainingProgramTest < ActiveSupport::TestCase
  test "tracks progress correctly" do
    program = create(:training_program)
    membership = create(:training_membership, training_program: program)
    
    membership.update_progress(content_id: 1, status: "completed")
    assert_equal "completed", membership.content_status(1)
  end
end
```

### System Tests

```ruby
# test/system/training_player_test.rb
class TrainingPlayerTest < ApplicationSystemTestCase
  test "completes video module" do
    sign_in_as users(:employee)
    visit training_program_path(@program)
    
    click_on "Start Video"
    assert_text "Video Progress: 0%"
    
    # Simulate video completion
    page.execute_script("window.completeVideo()")
    assert_text "Video Progress: 100%"
  end

  test "generates certificate upon completion" do
    sign_in_as users(:employee)
    complete_training(@program)
    
    assert_text "Generate Certificate"
    click_on "Generate Certificate"
    assert_text "Certificate generated successfully"
  end
end
```

---

Remember: Rely on Bullet Train's built-in patterns for authentication, API versioning, and asset management. This guide focuses only on the changes required beyond the standard boilerplate.
