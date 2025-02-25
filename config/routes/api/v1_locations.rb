# API V1 Routes for Locations with GeoJSON support
namespace :v1 do
  resources :teams do
    resources :locations do
      collection do
        get :near
      end
    end
  end

  resources :locations, only: %i[show update destroy] do
    member do
      get :children
    end
  end
end
