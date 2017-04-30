Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'main#index'

  # signup
  get 'signup' => 'signup#new'
  post 'signup' => 'signup#create'
  # sessions
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  # delete 'logout' => 'sessions#destroy'
  get 'logout' => 'sessions#destroy'

  # account
  get 'account' => 'account#index'
  get 'account/password'
  get 'account/credit_cards'

  # My Restaurant
  get 'account/myrestaurant', to: 'account#myrestaurant'
  # dashboard
  get 'dashboard', to: 'dashboard#index'
  get 'dashboard/table'
  get 'dashboard/schedule'
  get 'dashboard/service'
  # menu
  resources :menu_items

  # queue
  get 'queue', to: 'queue#index'
  get 'queue/login'
  get 'queue/logout'

  # Restaurants
  resources :restaurants, only: [:index, :show] do
    member do
      get 'call'
      get 'reserve'
      get 'menu'
    end
  end

  # routes for Stripe credit cards charges
  resources :charges
end
