# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.0.2'

group :preload do
	gem 'utopia', '~> 2.18.5'
	# gem 'utopia-gallery'
	# gem 'utopia-analytics'
	
	gem 'variant'
end

gem 'rake'
gem 'bake'
gem 'bundler'
gem 'rack-test'

gem 'async-http'
gem 'thread-local'

gem 'trenni-formatters'

group :development do
	gem 'guard-falcon', require: false
	gem 'guard-rspec', require: false
	
	gem 'rspec'
	gem 'covered'
	
	gem 'async-rspec'
	gem 'benchmark-http'
end

group :production do
	gem 'falcon'
end
