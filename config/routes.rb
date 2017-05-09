Rails.application.routes.draw do
  # home
  root to: 'main#index'

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

  get '/history' => 'users#history'
  get '/reservations' => 'users#reservations'

  # dashboard(redirect from /restaurant/:id/edit)
  # get '/dashboard' => 'restaurants#edit'
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
    resources :walkins
    # get 'walkins' => 'walkins#index'
    # post 'walkins' => 'walkins#create'
    # get 'walkins/new' => 'walkins#new', as: 'new_walkin'
    # get 'walkins/:id/edit' => 'walkins#edit', as: 'edit_walkin'
    # get 'walkins/:id' => 'walkins#show', as: 'walkin'
    # put 'walkins/:id' => 'walkins#update'
    # delete 'walkins/:id' => 'walkins#destroy'
    get 'public' => 'walkins#public_show'
    post 'public' => 'walkins#public_create'
    get 'public/new' => 'walkins#public_new', as: 'new_public'
    put 'notify/:id' => 'walkins#notify', as: 'notify'
    put 'requeue/:id' => 'walkins#requeue', as: 'requeue'
    get 'diners' => 'diners#index'
    get 'diners/:id/edit' => 'diners#edit', as: 'edit_diner'
    get 'diners/:id' => 'diners#show', as: 'diner'
    put 'diners/:id' => 'diners#update'
    put 'reset_queue' => 'restaurants#reset_queue'
  end
end
