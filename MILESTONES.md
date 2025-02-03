---

# Training Program Player w/ Vue.js

The task is to integrate a Vue.js component into an existing Bullet Train Rails application to display training programs, handle user progress, and utilize JWT authentication. The provided code shows a basic Rails controller for managing training programs. We need to enhance this controller to handle API requests and the frontend to handle JWT authentication and user progress.

Overall Steps:

1. **Backend Setup (Rails):** Configure JWT authentication, create or modify API endpoints, and update the database schema.
2. **Frontend Setup (Vue.js):** Create the Vue.js component structure, install dependencies, and configure Tailwind CSS.
3. **API Integration (Frontend):** Implement API calls for fetching training program data and updating progress.
4. **Component Implementation (Frontend):** Build the `VideoPlayer`, `QuestionsPanel`, and `StepProgress` components.
5. **Progress Management (Frontend/Backend):** Implement mechanisms for storing and updating user progress.
6. **Integration and Testing:** Integrate the Vue component into your Rails view, test thoroughly, and address any issues.

-----

## Step 1: Backend Setup (Rails)

This step focuses on preparing the Rails backend to handle JWT authentication and API requests for training programs.

### 1.1 Choose a JWT Gem:

Select a suitable JWT gem for Rails (e.g., `devise_token_auth`, `knock`). `devise_token_auth` is a popular choice, providing a comprehensive solution including user authentication and JWT management. Install the gem using:
```
bundle add devise_token_auth
```

### 1.2 Configure the Chosen JWT Gem:

Follow the gem's installation and configuration instructions. This typically involves:

- Generating models and controllers as instructed by the gem.
- Adding necessary routes for authentication (e.g., `/auth/sign_in`, `/auth/sign_up`, etc.).
- Configuring database columns (if needed) to support the gem's functionality.
- Adding authentication middleware to your application to verify JWTs on relevant API requests.

### 1.3 Modify the `Account::TrainingProgramsController`:

**Authentication:** Use the JWT gem's functionality to authenticate users before allowing API access. This would likely involve a `before_action` in your controller. An example using `devise_token_auth`:

```ruby
before_action :authenticate_user!, only: [:show, :update_progress] # Only these actions require authentication.
```

**`show` Action:** Modify the `show` action to include the user's progress data:

```ruby
def show
  # Verify JWT authentication (if not handled by before_action)
  training_membership = current_user.training_memberships.find_by(training_program: @training_program)
  progress_data = training_membership&.progress || {} # Default to empty hash if no progress exists
  render json: @training_program.as_json(include: [:training_contents, training_contents: [:training_questions]]).merge(progress: progress_data)
end
```

**`update_progress` Action:** Add a new action to handle progress updates:

```ruby
def update_progress
  training_membership = current_user.training_memberships.find_by(training_program: @training_program)
  if training_membership
    training_membership.update(progress: params[:progress])
    head :ok # Or send a success message
  else
    render json: { error: 'Training membership not found' }, status: :not_found
  end
end
```

**Error Handling:** Add error handling in both actions to gracefully handle issues (e.g., `ActiveRecord::RecordNotFound`).

**Authorization:** Add authorization checks to ensure only authorized users can access training programs and update their progress. (Use Pundit or CanCanCan).

### 1.4 Update Database Schema:

Add a `progress` column (JSONB data type) to the `training_memberships` table if it doesn't exist already:

```ruby
class AddProgressToTrainingMemberships < ActiveRecord::Migration[7.0]
  def change
    add_column :training_memberships, :progress, :jsonb, default: {}
  end
end
```

Run this migration using:
```
bin/rails db:migrate
```

### 1.5 Define API Routes:

Modify your `config/routes.rb` to include the API routes for your `Account::TrainingProgramsController`:

```ruby
namespace :api do
  namespace :v1 do # Versioning is recommended
    resources :training_programs, only: [:show] do
      member do
        put :update_progress
      end
    end
  end
end
```

### 1.6 Testing:

Write tests to validate the authentication, authorization, and functionality of the API endpoints.

This completes the backend setup. The next step involves setting up the frontend Vue.js component. Remember to restart your Rails server after making changes to the database or routes.

-----

- Select JWT gem for Rails (e.g., `devise_token_auth`).
- Install the chosen JWT gem and configure it as per its instructions.
- Modify the `Account::TrainingProgramsController` for authentication, authorization, and API endpoints.
- Update database schema to include a `progress` column in the `training_memberships` table (JSONB data type).
- Define API routes for your `Account::TrainingProgramsController`.
- Write tests for authentication, authorization, and functionality of the API endpoints.
## Step 2: Frontend Setup (Vue.js)

This step focuses on setting up the necessary Vue.js project structure, installing dependencies, and configuring Tailwind CSS for styling. Because you're integrating this into an existing Rails application, we'll assume you're using Webpacker or a similar asset pipeline.

### 2.1 Project Setup (Within Rails):

- **Create a directory:** Create a directory within your Rails application's `app/javascript` directory (e.g., `app/javascript/training-program-viewer`). This will contain all your Vue.js files.

- **Create main component:** Inside the directory, create the main component file (`TrainingProgramViewer.vue`):

  ```vue
  <template>
    <div>
      <!-- Your component content will go here -->
    </div>
  </template>

  <script setup>
    // Your Vue.js logic will go here
  </script>
  ```

- **Create other component files:** Create other components (`VideoPlayer.vue`, `QuestionsPanel.vue`, `StepProgress.vue`) within the same directory following similar template structure.

### 2.2 Install Dependencies (via npm or yarn):

- Navigate to your `app/javascript` directory in the terminal.
- Install the required packages using `npm` or `yarn`. Use `npm install` or `yarn add` to install the packages:
  - `axios`: For making HTTP requests to your Rails API.
  - `@formkit/vue`: For building forms.
  - `@headlessui/vue`: For UI components.
  - `@tailwindcss/forms`: For Tailwind CSS form styles.
  - `pinia`: Vuex-like state management.
  - `vue-use-cloudinary`: For Cloudinary video integration. (Alternatives exist).
  - `@vueuse/motion`: For animations (optional).
  - `zod`: For runtime type validation of data.

### 2.3 Configure Tailwind CSS:

If your Rails app doesn't already use Tailwind CSS, you'll need to integrate it. This is generally done via a gem like `tailwindcss-rails`.

**Important:** Ensure Tailwind CSS is correctly configured and includes your Vue.js components in the `content` section of your `tailwind.config.js`. You may need to adjust the paths to accurately point to your Vue.js components. An example `tailwind.config.js` snippet:

```js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/views/**/*.html.erb", // Add your Rails views here
    "./app/javascript/**/*.vue"  // Add your Vue.js components here
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

Run the necessary commands to build and include the Tailwind CSS output in your application (as detailed in the documentation for your chosen gem). You'll likely need to run a command like:
```
rails tailwindcss:install
```
followed by
```
rails tailwindcss:setup
```
and potentially others to generate necessary files and add Tailwind directives to your CSS.

### 2.4 Set up Pinia Stores:

Create Pinia stores (e.g., `useAuthStore.js`, `useTrainingProgramStore.js`) within your `app/javascript/training-program-viewer` directory to manage your application's state. These will likely live in separate files.

```js
// useAuthStore.js
import { defineStore } from 'pinia';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: null,
    user: null,
  }),
  actions: {
    setToken(token) {
      this.token = token;
    },
    setUser(user) {
      this.user = user;
    },
  },
});
```

```js
// useTrainingProgramStore.js
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
          // ... (Implementation for updating progress)
      }
  },
});
```

### 2.5 Import and use Pinia:

In your `TrainingProgramViewer.vue` component, import and use the Pinia stores:

```vue
<script setup>
import { onMounted } from 'vue';
import { useAuthStore } from './useAuthStore';
import { useTrainingProgramStore } from './useTrainingProgramStore';

const authStore = useAuthStore();
const trainingProgramStore = useTrainingProgramStore();

onMounted(async () => {
    await trainingProgramStore.fetchTrainingProgram(1); // Replace 1 with the actual ID
});
</script>
```

### 2.6 Webpacker Configuration (If Necessary):

If your Rails application uses Webpacker, ensure that your Vue.js component is properly included in your webpack configuration. This might involve adding an entry point for your Vue component.

This detailed plan will get your frontend project up and running, ready for API integration. Remember to test the functionality of your stores. You'll likely need to adjust paths based on your project structure.

-----

- Create a Vue.js project structure within Rails.
- Install necessary packages using npm or yarn (axios, @formkit/vue, etc.).
- Configure Tailwind CSS for styling.
- Set up Pinia stores for state management.
- Import and use Pinia in the `TrainingProgramViewer` component.
## Step 3: API Integration (Frontend)

### 3.1 Setting Up Axios Interceptors
- Create a dedicated Axios instance that attaches the JWT token to every request.
- Handle request/response interceptors for adding headers and managing errors.

### 3.2 Enhancing the Pinia Store
- Modify the fetchTrainingProgram and updateProgress actions to use the Axios instance.
- Manage loading and error states in a similar manner as Step 1 & 2.

### 3.3 JWT Handling in Auth Store
- Add methods to store, retrieve, and clear JWT tokens from localStorage.
- Handle login/logout using the appropriate Rails authentication endpoints.

### 3.4 Error Management
- Use try/catch blocks in store actions to centralize error handling.
- Optionally display user-friendly error messages based on status codes.

### 3.5 Integration with Main Component
- On component mount, fetch the required data (e.g., training program details).
- Update progress on user actions by calling store methods.

-----

- Create Axios interceptors for handling requests and responses.
- Enhance the Pinia store with methods to fetch training program data and update progress.
- Implement JWT handling in Auth Store for login/logout, retrieving, and clearing tokens from localStorage.
- Manage loading and error states within store actions.
- Integrate store actions into the main component for fetching data and updating progress on user actions.
## Step 4: Component Implementation (Frontend)

### 4.1 VideoPlayer.vue
- Accept a videoUrl prop and emit an event upon video completion.
- Use native video controls or integrate a custom video player if desired.

### 4.2 QuestionsPanel.vue
- Render questions with a form kit library for flexible input types.
- Emit a submit event or call store actions to update progress after user responses.

### 4.3 StepProgress.vue
- Display a progress bar or step indicator based on current and total slides.
- Keep it visually consistent with the rest of the application’s styling.

### 4.4 Data Structures
- Ensure question object formats align with @formkit/vue.
- Clearly define and maintain consistent data shapes between frontend and backend.

### 4.5 Integration
- Pass props from the main viewer component to these sub-components.
- Handle emitted events (e.g., videoEnded, formSubmitted) to synchronize progress with the store.

-----

- Develop `VideoPlayer`, `QuestionsPanel`, and `StepProgress` components with appropriate functionality and props.
- Ensure consistent data structures between frontend and backend.
- Pass props from the main component to these sub-components.
- Handle emitted events for synchronizing progress with the store.
## Step 5: Progress Management (Frontend/Backend)

This step focuses on implementing mechanisms for storing and updating user progress in both the frontend and backend.

### 5.1 Backend Progress Management
- Ensure the `update_progress` action in the Rails controller updates the user's progress in the database.
- Add necessary validations and error handling to ensure data integrity.

### 5.2 Frontend Progress Management
- Use the Pinia store to manage the user's progress state.
- Update the progress state in the store whenever the user completes a video or submits answers to questions.
- Persist the progress state to the backend using the `updateProgress` action in the Pinia store.

### 5.3 Synchronization
- Ensure the frontend and backend progress states are synchronized.
- Fetch the user's progress from the backend when the component mounts and update the store accordingly.

-----

- Implement mechanisms in the Rails controller's `update_progress` action for updating user progress in the database.
- Use the Pinia store to manage the user's progress state on the frontend and update it with the `updateProgress` action.
- Ensure synchronization between frontend and backend progress states during data fetching and updates.
## Step 6: Integration and Testing

This step focuses on integrating the Vue component into your Rails view, testing thoroughly, and addressing any issues.
- Integrate the Vue component into your Rails view template and handle data passing if necessary.
- Implement a thorough testing strategy for both frontend and backend, including unit, integration, and API tests.
- Handle errors appropriately on both the frontend and backend for network errors, API errors, validation errors, etc.
- Ensure that Vue assets are correctly included in your Rails asset pipeline (Webpacker) and serve to the client.
- Test thoroughly on deployment environment before release to production.

### 6.1 Integration
- Integrate the `TrainingProgramViewer.vue` component into your Rails view.
- Ensure the component is properly rendered and receives the necessary props.
## Additional Notes: Training Program Viewer Integration

### 6.2 Testing
- Test the functionality of the Vue component, including video playback, question submission, and progress updates.
- Test the API endpoints to ensure they handle requests correctly and return the expected responses.
- Address any issues that arise during testing and ensure the application works as expected.

### 6.3 Deployment
- Deploy the application to your production environment.
- Monitor the application for any issues and address them promptly.

This detailed plan will guide you through the entire process of integrating a Vue.js component into a Rails application, from backend setup to frontend implementation and testing. Remember to test thoroughly and address any issues that arise during the process.

- Frontend: Implement state management, error handling, security measures, responsiveness, accessibility, loading states, internationalization support, and a testing strategy.
- Backend: Implement API versioning, secure JWT authentication, authorization controls, data validation, database optimization, and logging.
- Integration: Ensure asset pipeline configuration, Rails view integration, data serialization consistency, and thorough testing on deployment environment before release to production.
- Specific to Bullet Train: Carefully integrate JWT authentication with existing system, ensure theme integration, use existing models effectively, and maintain compatibility.
- Implement mechanisms in the Rails controller's `update_progress` action for updating user progress in the database.
- Use the Pinia store to manage the user's progress state on the frontend and update it with the `updateProgress` action.
- Ensure synchronization between frontend and backend progress states during data fetching and updates.
## Step 6: Integration and Testing

This step focuses on integrating the Vue component into your Rails view, testing thoroughly, and addressing any issues.

### 6.1 Integration
- Integrate the `TrainingProgramViewer.vue` component into your Rails view.
- Ensure the component is properly rendered and receives the necessary props.

### 6.2 Testing
- Test the functionality of the Vue component, including video playback, question submission, and progress updates.
- Test the API endpoints to ensure they handle requests correctly and return the expected responses.
- Address any issues that arise during testing and ensure the application works as expected.

### 6.3 Deployment
- Deploy the application to your production environment.
- Monitor the application for any issues and address them promptly.

This detailed plan will guide you through the entire process of integrating a Vue.js component into a Rails application, from backend setup to frontend implementation and testing. Remember to test thoroughly and address any issues that arise during the process.


- Integrate the Vue component into your Rails view template and handle data passing if necessary.
- Implement a thorough testing strategy for both frontend and backend, including unit, integration, and API tests.
- Handle errors appropriately on both the frontend and backend for network errors, API errors, validation errors, etc.
- Ensure that Vue assets are correctly included in your Rails asset pipeline (Webpacker) and serve to the client.
- Test thoroughly on deployment environment before release to production.

## Additional Notes: Training Program Viewer Integration

- Frontend: Implement state management, error handling, security measures, responsiveness, accessibility, loading states, internationalization support, and a testing strategy.
- Backend: Implement API versioning, secure JWT authentication, authorization controls, data validation, database optimization, and logging.
- Integration: Ensure asset pipeline configuration, Rails view integration, data serialization consistency, and thorough testing on deployment environment before release to production.
- Specific to Bullet Train: Carefully integrate JWT authentication with existing system, ensure theme integration, use existing models effectively, and maintain compatibility.
### 6.4 Deployment:
- **Asset Pipeline:** Ensure your Vue.js code is correctly bundled and served by your Rails application.
- **Server-Side Rendering (Optional):** If needed, configure your Rails app to render the Vue.js component on the server.

This final step is crucial for ensuring the reliability and correctness of your integrated application. Remember to address any issues that arise during testing and iterate on your implementation until it functions flawlessly.

---

## Additional Notes: Training Program Viewer Integration

This section provides additional considerations and recommendations for a successful integration of the Vue.js training program viewer into your Bullet Train Rails application. It covers frontend, backend, integration, and specifics to Bullet Train topics.

### I. Frontend Considerations:
- **State Management:** Consider using Pinia for state management in smaller applications; use a more robust solution if the application is very large.
- **Error Handling:** Implement comprehensive error handling for network errors, API errors, and validation errors from @formkit/vue.
- **Security:** Avoid storing sensitive information like JWTs directly in localStorage; consider secure alternatives.
- **Responsiveness:** Ensure your Vue components are responsive and adapt well to different screen sizes using Tailwind CSS.
- **Accessibility:** Adhere to accessibility best practices when designing your components using ARIA attributes, semantic HTML, and Headless UI.
- **Loading States:** Display clear loading indicators while fetching data or submitting answers.
- **Internationalization (i18n):** Consider adding internationalization support for multiple languages if needed.
- **Testing Strategy:** Implement a robust testing strategy including unit, integration, and end-to-end tests.

### II. Backend Considerations:
- **API Versioning:** Implement API versioning to allow future changes without breaking existing clients.
- **Authentication Security:** Secure your JWT authentication using HTTPS and consider refresh tokens for session extension.
- **Authorization:** Use gems like Pundit or CanCanCan to implement fine-grained authorization controls.
- **Data Validation:** Validate all data received from the frontend before persisting it to the database using strong parameters or similar mechanisms.
- **Database Optimization:** For large training programs or a high volume of users, optimize your database queries and schema for improved performance.
- **Logging:** Implement proper logging to track API requests, errors, and other important events.

### III. Integration Considerations:
- **Asset Pipeline:** Ensure that your Vue.js assets are correctly included in your Rails asset pipeline (Webpacker) and served to the client. Test thoroughly on your deployment environment.
- **Rails View Integration:** Use a clean and maintainable way to integrate the Vue component into your Rails view, potentially using a component library like Stimulus.
- **Data Serialization:** Ensure that data serialization from your Rails API is consistent with the expected data structure in your Vue components using ActiveModelSerializers.
- **Deployment:** Test your entire application thoroughly on your deployment environment before releasing it to production.

### IV. Specific to Bullet Train:
- **Authentication Integration:** Carefully integrate the JWT authentication with Bullet Train's existing authentication system.
- **Theme Integration:** Ensure that your Vue component styling integrates seamlessly with your chosen Bullet Train theme.
- **Existing Models:** Use your existing models and associations effectively to avoid redundancy.

By considering these additional points, you can significantly improve the quality, security, and maintainability of your integrated application. Iterative development and thorough testing are essential for success.