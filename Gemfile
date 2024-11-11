# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'zeitwerk'
gem 'bundle-audit'
gem 'bcrypt'
gem 'sinatra', '~>2.2.3'
gem 'sinatra-contrib'
gem 'multi_json'
gem 'oj'
gem 'sequel'

# Dry
gem 'dry-configurable', '~>0.13.0'
gem 'dry-validation'
gem 'dry-struct'
gem 'dry-types'
gem 'dry-monads'
gem 'dry-initializer'

gem 'puma', '~>5.6.7'
gem 'rack', '~>2.2.8'
gem 'racksh'
gem 'thor'
gem 'pg'
gem 'mysql2'

group :development, :test do
  gem 'rubocop'
  gem 'rubocop-sequel'
  gem 'rubocop-rspec'
  gem 'rubocop-performance'
  gem 'reek'
end

group :test do
  gem 'rspec'
  gem 'database_cleaner-sequel'
end
