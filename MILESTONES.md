# Training Program Player w/ Vue.js

This guide details the custom enhancements needed to integrate a Training Program Viewer into your Bullet Train Rails application. Built on top of Bullet Train’s out-of-the-box authentication, API, and asset configuration, the following steps focus on the VendorSafe application’s unique requirements.

---

## Overall Steps

1. **Backend Enhancements (Rails)**
   - Add custom actions for retrieving and updating training progress.
   - Extend existing models/migrations as needed.
2. **Frontend Enhancements (Vue.js)**
   - Create a training program viewer in the `app/javascript/training-program-viewer` directory.
   - Leverage the pre-installed Tailwind CSS, Vue, and Pinia stores from the Bullet Train boilerplate.
3. **API Integration**
   - Use Bullet Train’s built-in API patterns to fetch and update training data.
4. **Component Implementation**
   - Build and wire up `VideoPlayer`, `QuestionsPanel`, and `StepProgress` components.
5. **Progress Management**
   - Sync training progress between frontend and backend.
6. **Integration and Testing**
   - Embed the Vue component into your Bullet Train view and test the interactions.

---

## Step 1: Backend Enhancements (Rails)

Bullet Train already provides authentication and API scaffolding. In this step you only need to extend those defaults for your training program.

### 1.1 Custom Controller Actions
Add training progress logic in your existing API controller (e.g. under `app/controllers/api/v1/training_programs_controller.rb`):

```ruby
// ...existing code...
before_action :authenticate_user!, only: [:show, :update_progress]

def show
  training_membership = current_user.training_memberships.find_by(training_program: @training_program)
  progress_data = training_membership&.progress || {}
  render json: @training_program.as_json(
    include: [:training_contents, training_contents: [:training_questions]]
  ).merge(progress: progress_data)
end

def update_progress
  training_membership = current_user.training_memberships.find_by(training_program: @training_program)
  if training_membership
    training_membership.update(progress: params[:progress])
    head :ok
  else
    render json: { error: 'Training membership not found' }, status: :not_found
  end
end
// ...existing code...
```

### 1.2 Database Update
If not already present, add the `progress` field (using Bullet Train migration conventions):

```ruby
// filepath: /path/to/new_migration_file.rb
class AddProgressToTrainingMemberships < ActiveRecord::Migration[7.0]
  def change
    add_column :training_memberships, :progress, :jsonb, default: {}
  end
end
```
Then run:
```
bin/rails db:migrate
```

### 1.3 API Routes
Bullet Train already manages API versioning. Simply extend your API routes in `config/routes.rb`:

```ruby
// ...existing code...
namespace :api do
  namespace :v1 do
    resources :training_programs, only: [:show] do
      member do
        put :update_progress
      end
    end
  end
end
// ...existing code...
```

---

## Step 2: Frontend Enhancements (Vue.js)

Bullet Train’s boilerplate already configures Tailwind, Vue, and asset compilation. Create your custom components under `app/javascript/training-program-viewer`.

### 2.1 Project Structure
Create these files if they don’t exist:
- `TrainingProgramViewer.vue`
- `VideoPlayer.vue`
- `QuestionsPanel.vue`
- `StepProgress.vue`

### 2.2 Dependencies
Since the Bullet Train boilerplate already includes Tailwind CSS and basic Vue setup, only add additional dependencies (if any) via npm/yarn.

### 2.3 Pinia Stores
Extend or create stores using Bullet Train’s conventions. For example, define an auth store (if not already present) and add a training program store:

```js
// filepath: /app/javascript/training-program-viewer/useTrainingProgramStore.js
import { defineStore } from 'pinia';
import axios from 'axios';

export const useTrainingProgramStore = defineStore('trainingProgram', {
  state: () => ({
    trainingProgram: null,
    isLoading: false,
    error: null,
  }),
  actions: {
    async fetchTrainingProgram(id) {
      this.isLoading = true;
      this.error = null;
      try {
        const response = await axios.get(`/api/v1/training_programs/${id}`);
        this.trainingProgram = response.data;
      } catch (error) {
        this.error = error;
      } finally {
        this.isLoading = false;
      }
    },
    updateProgress(progressData) {
      // ...implementation using axios...
    },
  },
});
```

### 2.4 Component Integration
Import and use your stores in your main component. For example, in `TrainingProgramViewer.vue`:

```vue
// filepath: /app/javascript/training-program-viewer/TrainingProgramViewer.vue
<script setup>
import { onMounted } from 'vue';
import { useTrainingProgramStore } from './useTrainingProgramStore';

const trainingProgramStore = useTrainingProgramStore();

onMounted(async () => {
  await trainingProgramStore.fetchTrainingProgram(1); // Adjust ID as needed
});
</script>

// ...template and style sections...
```

---

## Step 3: API Integration

Use Bullet Train’s default Axios setup (which may include JWT interceptors) to make API calls. Simply update your store actions to use the existing configuration.

```js
// ...useTrainingProgramStore.js remains as above...
```

---

## Step 4: Component Implementation

Implement your Vue components following the Bullet Train styling conventions:

- In `VideoPlayer.vue`, accept a `videoUrl` prop and emit an event on video completion.
- In `QuestionsPanel.vue`, render your questions and emit submit events.
- In `StepProgress.vue`, display the progress using your preferred UI patterns.

// ...existing code in each component remains or is extended...

---

## Step 5: Progress Management

Leverage your extended API endpoints and Pinia stores to synchronize training progress between frontend and backend. The built-in Bullet Train API patterns handle most of the heavy lifting.

---

## Step 6: Integration and Testing

Embed your `TrainingProgramViewer.vue` within an Account view and verify that:
- The component fetches training data using Bullet Train’s API.
- Training progress updates correctly using your custom endpoint.
- Vue components adhere to Bullet Train’s asset pipeline and styling conventions.

Write tests as needed using your standard Bullet Train testing strategy.

---

Remember: Rely on Bullet Train’s built-in patterns for authentication, API versioning, and asset management. This guide focuses only on the changes required beyond the standard boilerplate.



