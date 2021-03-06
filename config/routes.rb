Rails.application.routes.draw do
  # home
  root to: 'restaurants#index'

  # serve websocket cable requests
  mount ActionCable.server, at: '/cable'

  # route for Twilio SMS
  post '/messages/receive' => 'twilio#receive'

  # users
  devise_for :users, path: '/', path_names: {
    sign_up: 'register',
    sign_in: 'login',
    sign_out: 'logout',
    edit: 'account'
  }
  get '/invoices' => 'users#invoices'
  get '/reservations' => 'users#reservations'

  # restaurant management
  get '/dashboard' => 'dashboard#index'

  # restaurants
  resources :restaurants do
    resources :reservations
    resources :menu_items
    resources :tables
    resources :invoices, except: [:new] do
      resources :orders
    end
    # display all orders
    get 'orders' => 'orders#index'

    resources :walkins, except: [:show, :edit]
    get 'public' => 'walkins#public_show'
    post 'public' => 'walkins#public_create'
    get 'public/new' => 'walkins#public_new', as: 'new_public'

    put 'notify/:id' => 'walkins#notify', as: 'notify'
    put 'requeue/:id' => 'walkins#requeue', as: 'requeue'
    put 'seated/:id' => 'walkins#seated', as: 'seated'
    put 'cancelled/:id' => 'diners#cancelled', as: 'cancelled'
    put 'checked_out/:id' => 'diners#checked_out', as: 'checked_out'

    get 'diners' => 'diners#index'
    get 'diners/:id/edit' => 'diners#edit', as: 'edit_diner'
    get 'diners/:id' => 'diners#show', as: 'diner'
    put 'diners/:id' => 'diners#update'

    put 'reset_queue' => 'restaurants#reset_queue'
  end
end
