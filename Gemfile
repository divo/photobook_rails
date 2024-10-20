source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.6'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.4'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgres the database for Active Record
gem 'pg'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
gem 'sidekiq'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
gem 'sassc-rails'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing', '~> 1.2'
gem 'ruby-vips'

# B O O T S T R A P
gem 'bootstrap', '~> 5.0'
gem 'jquery-rails'

# HTTParty to call other services
gem 'httparty'

# exif analyzer to read image metadata
gem 'exif'

# geocoder for place name
gem 'geocoder'

# down gem, because Open URI changes it's mind about what a file is
gem 'down', '~> 5.0'

# Gush for job coordination
gem 'gush', '~> 2.1'

# Devise for users and auth
gem 'devise'

# S3 SDK
gem 'aws-sdk-s3'

# Fix for rails console not working with ruby 3.0.4
gem 'irb'

# Country select during user registration so shipping can be estimated
gem 'country_select', '~> 8.0'

# For displaying currency symbols
gem 'money-rails', '~> 1.15'

# For checkout
gem 'stripe', '~> 8.3'

# State machine. I don't think this is overkill, I need a decent way to control order state
gem 'aasm', '~> 5.5'
gem 'after_commit_everywhere', '~> 1.3'

gem 'countries', '~> 5.3'

gem 'soft_deletion'

gem 'meta-tags'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]

  # dotenv for config
  gem 'dotenv-rails'

  # sitemap generation
  gem 'sitemap_generator'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem 'byebug'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
