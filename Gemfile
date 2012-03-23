# /opt/local/tophat/tophat.sh

source 'http://rubygems.org'
source "http://gems.github.com"

gem 'rails' #, '3.0.9'
require 'rake/dsl_definition'
gem 'rake', '0.9.2'


# gem "thin", "1.2.11"
# http://macournoyer.wordpress.com/2008/01/03/thin-a-fast-and-simple-web-server/
# gem "mongrel"

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# gem 'sqlite3-ruby', '1.2.5', :require => 'sqlite3'
gem 'sqlite3-ruby'
# gem 'mysql'

gem 'nokogiri'

gem "haml-rails"
gem "sass"

# rails generate jquery:install --ui
gem "jquery-rails"

# rails g devise:install => config/initializers/devise.rb
# rails g nifty:authentication
gem "devise" #, :git => 'git://github.com/plataformatec/devise.git'

# gem "rubyzip", :require => 'zip/zip'
gem "zippy"

# documentation in html and manpage format
# https://github.com/rtomayko/ronn
gem "ronn", "~> 0.7.3"


# Gem for generating the /admin side
# rails g active_admin:install
# https://github.com/gregbell/active_admin
# http://activeadmin.info/
# http://activeadmin.info/documentation.html
# rails generate active_admin:resource [MyModelName]
# gem 'activeadmin'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
#   gem 'webrat'
  gem 'nifty-generators'
  gem 'daemons'
end
# gem "mocha", :group => :test
# gem "bcrypt-ruby", :require => "bcrypt"
