Rails.application.routes.draw do
  get 'user_controller/new'
  get 'users/new'
  root             'static_pages#home'
  get 'help'    => 'static_pages#help'
  get 'signup'  => 'users#new'
end