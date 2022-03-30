source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 4.3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Use Pry for console
gem 'pry'
# Use Faker for seeding data
gem 'faker'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Add Stripe integration for credit cards
gem 'stripe'
# Add Devise for authentication
gem 'devise'
# Use bcrypt for Devise
gem 'bcrypt', '~> 3.1.7'
# Add Gon for javascript things
gem 'gon'
# Add Twilio for SMS
gem 'twilio-ruby'
# Add Materialize CSS framework
gem 'materialize-sass'
# Gem for offline Materialize icons
gem 'material_icons'
# Gem for pagination (Thanks Raymond!)
gem 'will_paginate-materialize'
# Add Cloudinary for image upload/storage
gem 'cloudinary'
# Add Foreman to save environment variables to .env
gem 'foreman'
# Add RestClient for Mailgun
gem 'rest-client'

# Add the stupid breadcrumb things
gem "breadcrumbs_on_rails"

# Gem to use jquery with Materialize
gem 'jquery-turbolinks'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'

# gem 'bcrypt-ruby', '3.1.2'

# Email Validator
gem 'email_validator'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  # # Use sqlite3 as the database for Active Record
  # gem 'sqlite3'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# group :production do
#   gem 'pg'
# end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
