Rails.application.routes.draw do
  get 'home/home'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # routes for Stripe credit cards charges
  root 'home#home'
  resources :charges
end
