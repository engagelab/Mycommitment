require 'sinatra'
require 'mongoid'
require 'digest'
require 'uri'
require 'json'
require 'fileutils'
require 'aws/s3'
require 'securerandom'
require 'logger'
require 'bcrypt'


class Gamification < Sinatra::Application
  include BCrypt

  set :environment, :production
  set :public_folder, 'public'

  configure do
    set :app_file, __FILE__
    Mongoid.load! "#{File.dirname(__FILE__)}/config/mongoid.yml"
  end

  configure :development do
    enable :logging, :dump_errors, :raise_errors
  end

  configure :production do
    set :raise_errors, false #false will show nicer error page
    set :show_exceptions, false #true will ignore raise_errors and display backtrace in browser
  end

  # Executes a login
  get '/' do
    'Hello mycommitment'
  end
end