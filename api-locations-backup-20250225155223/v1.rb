# See `config/routes.rb` for details.
collection_actions = %i[index new create] # standard:disable Lint/UselessAssignment
extending = { only: [] }

shallow do
  namespace :v1 do
    # user specific resources.
    resources :users, extending do
      namespace :oauth do
        # 🚅 super scaffolding will insert new oauth providers above this line.
      end

      # routes for standard user actions and resources are configured in the `bullet_train` gem, but you can add more here.
    end

    # team-level resources.
    resources :teams, extending do
      # routes for many teams actions and resources are configured in the `bullet_train` gem, but you can add more here.

      # add your resources here.

      resources :invitations, extending do
        # routes for standard invitation actions and resources are configured in the `bullet_train` gem, but you can add more here.
      end

      resources :memberships, extending do
        # routes for standard membership actions and resources are configured in the `bullet_train` gem, but you can add more here.
      end

      namespace :integrations do
        # 🚅 super scaffolding will insert new integration installations above this line.
      end

      # Facilities routes - nested under teams
      resources :facilities, concerns: [:sortable]

      # Training Programs routes
      resources :training_programs do
        member do
          put :update_progress
          get :certificate
          post :generate_certificate
        end

        # Training Contents routes - nested under training_programs
        resources :training_contents, concerns: [:sortable] do
          # Training Questions routes - nested under training_contents
          resources :training_questions
        end
      end

      resources :locations, concerns: [:sortable]
      resources :pricing_models
    end

    # Non-nested routes for direct access
    resources :training_programs, only: %i[show update destroy] do
      member do
        put :update_progress
        get :certificate
        post :generate_certificate
      end
    end

    # Training Contents direct access
    resources :training_contents, only: %i[show update destroy] do
      # Training Questions routes - nested under training_contents for direct access
      resources :training_questions, shallow: true
    end

    # Training Questions direct access
    resources :training_questions, only: %i[show update destroy]

    # Facilities direct access
    resources :facilities, only: %i[show update destroy]

    resources :locations, only: %i[show update destroy]
    resources :pricing_models, only: %i[show update destroy]
  end
end
