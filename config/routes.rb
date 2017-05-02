Rails.application.routes.draw do
  # get 'reservations/index'
  # get 'reservations/create'
  # get 'reservations/new'
  # get 'reservations/edit'
  # get 'reservations/show'
  # get 'reservations/update'
  # get 'reservations/destroy'
  # get 'testing/hello'
  # get 'testing/moto'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'main#index'

  # Sessions
  get 'login' => 'sessions#new'
  # post 'login' => 'sessions#create'
  # delete 'logout' => 'sessions#destroy'
  # get 'logout' => 'sessions#destroy'

  # Users (Unique - /:id not accessible)
  resources :users
  # # signup
  # get 'signup' => 'users#new'
  # post 'signup' => 'users#create'
  # # account
  # get 'account' => 'users#show'
  # get 'account/edit' => 'users#edit'
  # put 'account/edit' => 'users#update'
  # credit_cards
  # get 'account/credit_cards'

  # Restaurant (Unique - /:id not accessible)
  # walk in queue
  # get 'queue' => 'queue#index'
  # get 'queue/login'
  # get 'queue/logout'
  # dashboard
  get 'dashboard' => 'dashboard#index'
  # get 'dashboard/table'
  # get 'dashboard/schedule'
  # get 'dashboard/service'

  # Public (Restaurants accessible by /:id)<--?
  resources :restaurants do
    resources :reservations
    resources :menu_items
    resources :tables
  end

  # routes for Stripe credit cards charges
  resources :charges
end
