Rails.configuration.stripe = {
  # :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
  :publishable_key => 'pk_test_9yHOz6zrh9nnjNOGLjV2Pvcq',
  # :secret_key => ENV['STRIPE_SECRET_KEY']
  :secret_key => 'sk_test_9Hc0EoVOPC0dvbMQeYxYLAt3'
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
