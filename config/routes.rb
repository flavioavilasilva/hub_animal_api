Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  post "/auth/login", to: "auth#login"
  resources :users

  mount Rswag::Ui::Engine => "/api-docs"
end
