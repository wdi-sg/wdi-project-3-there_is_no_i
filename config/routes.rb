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

  get 'messages/index'
  get 'messages/create'
  post 'messages/create'

  # Serve websocket cable requests in-process
  mount ActionCable.server, at: '/cable'

  # Restaurants
  resources :restaurants do
    resources :reservations
    resources :menu_items
    resources :tables
    resources :invoices do
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
    # get 'namesort' => 'reservations#name_sort', as: 'namesort'
    # get 'paxsort' => 'reservations#pax_sort', as: 'paxsort'
    # get 'datesort' => 'reservations#date_sort', as: 'datesort'
  end

  # routes for Stripe integration
  resources :charges
end
