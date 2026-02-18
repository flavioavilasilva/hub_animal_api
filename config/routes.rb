Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  post "/auth/login", to: "auth#login"
  resources :users
  resources :animals

  mount Rswag::Ui::Engine => "/api-docs"
end
