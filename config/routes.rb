require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # New route from the new code
  post '/api/todos/validate', to: 'todos#validate'

  # Existing namespace block from the existing code
  namespace :api do
    resources :todos, only: [:create]
  end
end
