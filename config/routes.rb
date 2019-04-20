Rails.application.routes.draw do
  resources :groups
  resources :team_members do
    collection { post :import }
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
