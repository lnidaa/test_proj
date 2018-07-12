Rails.application.routes.draw do
  get 'sessions/new'
  root             'static_pages#home'
  get 'help'    => 'static_pages#help'
  get 'signup'  => 'users#new'
  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'

  resources :users

end