Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'main#index'

  # Users
  devise_for :users, path: '/', path_names: {
    sign_up: 'register',
    sign_in: 'login',
    sign_out: 'logout',
    edit: 'account'
  }

  # dashboard(redirect from /restaurant/:id/edit)
  get '/dashboard' => 'restaurants#edit'

  # Serve websocket cable requests
  mount ActionCable.server, at: '/cable'

  # Restaurants
  resources :restaurants do
    resources :reservations
    resources :menu_items
    resources :tables
    resources :invoices do
      resources :orders
    end
    # display all orders
    get 'orders' => 'orders#index'
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
  end

  # route for Twilio
    get '/messages/receive' => 'twilio#receive'
end
