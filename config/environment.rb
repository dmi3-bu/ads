ENV['RACK_ENV'] ||= 'development'

require 'bundler/setup'
require 'sinatra'
require 'sinatra/url_for'
require 'rake'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'sinatra/custom_logger'
Bundler.require(:default, ENV['RACK_ENV'])

Dir['./app/models/*.rb'].sort.each { |file| require file }
Dir['./app/concerns/*.rb'].sort.each { |file| require file }
Dir['./app/serializers/*.rb'].sort.each { |file| require file }
Dir['./app/services/*.rb'].sort.each { |file| require file }
Dir['./app/services/**/*.rb'].sort.each { |file| require file }
Dir['./app/lib/**/*.rb'].sort.each { |file| require file }
require './app/application'
Dir['./config/initializers/*.rb'].sort.each { |file| require file }
