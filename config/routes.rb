Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'main#index'

  # auth
  get 'signup', to: 'main#signup'
  get 'login', to: 'main#login'
  get 'logout', to: 'main#logout'

  # account
  get 'account', to: 'account#index'
  get 'account/password'
  get 'account/credit_cards'

  # My Restaurant
  get 'myrestaurant', to: 'main#myrestaurant'
  # dashboard
  get 'dashboard', to: 'dashboard#index'
  get 'dashboard/table'
  get 'dashboard/schedule'
  get 'dashboard/service'
  # menu <---
  resources :menu_item

  # queue
  get 'queue', to: 'queue#index'
  get 'queue/login'
  get 'queue/logout'

  # Restaurants <---
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
