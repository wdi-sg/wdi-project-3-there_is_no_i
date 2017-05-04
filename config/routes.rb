Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'main#index'

  get 'messages/index'
  get 'messages/create'
  post 'messages/create'

  # Serve websocket cable requests in-process
  mount ActionCable.server, at: '/cable'

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
  # get 'queue' => 'queue#index'
  # get 'queue/login'
  # get 'queue/logout'
  # dashboard
  get 'dashboard' => 'dashboard#index'
  # get 'dashboard/table'
  # get 'dashboard/schedule'
  # get 'dashboard/service'

  # Restaurants
  resources :restaurants do
    resources :reservations
    resources :menu_items
    resources :tables
    resources :transactions do
      resources :orders
    end
    get 'walkins' => 'walkins#index'
    post 'walkins' => 'walkins#create'
    get 'walkins/new' => 'walkins#new', as: 'new_walkin'
    get 'public' => 'walkins#public_show'
    post 'public' => 'walkins#public_create'
    get 'public/new' => 'walkins#public_new', as: 'new_public'
    get 'walkins/:id/edit' => 'walkins#edit', as: 'edit_walkin'
    get 'walkins/:id' => 'walkins#show', as: 'walkin'
    put 'walkins/:id' => 'walkins#update'
    delete 'walkins/:id' => 'walkins#destroy'
    get 'diners' => 'diners#index'
    get 'diners/:id/edit' => 'diners#edit', as: 'edit_diner'
    get 'diners/:id' => 'diners#show', as: 'diner'
    put 'diners/:id' => 'diners#update'
    get 'namesort' => 'reservations#name_sort', as: 'namesort'
    get 'paxsort' => 'reservations#pax_sort', as: 'paxsort'
    get 'datesort' => 'reservations#date_sort', as: 'datesort'

  end

  # routes for Stripe credit cards charges
  resources :charges
end
