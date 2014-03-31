require 'sinatra'
require 'mongoid'
#require 'digest'
require 'uri'
require 'json'
require 'fileutils'
require 'aws/s3'
require 'securerandom'
require 'logger'
require 'bcrypt'


class Gamification < Sinatra::Application

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

  ######################## User ##################################
  ### list all storage
  get '/image' do
    content_type :json
    @storage = Storage.all()
    return @storage.to_json
  end

  get '/image/:image_id' do
    content_type :json
    storage = Storage.find(params[:image_id])
    storage.to_json
  end

  ## post image
  post '/image' do
    awskey     = ENV['AWS_ACCESS_KEY_ID']
    awssecret  = ENV['AWS_SECRET_ACCESS_KEY']
    bucket     = 'net.engagelab.mycommitment'
    file       = params[:file][:tempfile]
    filename   = params[:file][:filename]
    filextension = filename.split('.').last
    imageuid   = SecureRandom.uuid+'.'+filextension

    AWS::S3::DEFAULT_HOST.replace 's3-us-west-2.amazonaws.com'
    AWS::S3::Base.establish_connection!(
        :access_key_id     => awskey,
        :secret_access_key => awssecret
    )

    AWS::S3::S3Object.store(
        imageuid,
        open(file.path),
        bucket,
        :access => :public_read
    )

    if AWS::S3::Service.response.success?
      ui = Storage.create(:name => filename, :url => "http://#{bucket}.s3.amazonaws.com/#{imageuid}", :s3id => imageuid)
      return ui.to_json
    else
      error 404
    end
  end

  ### delete image
  delete '/image/:image_id' do
    request.body.rewind  # in case someone already read it
    content_type :json

    media = Storage.find(params[:image_id])

    if media.nil? then
      status 404
    else
      awskey     = ENV['AWS_ACCESS_KEY_ID']
      awssecret  = ENV['AWS_SECRET_ACCESS_KEY']
      bucket     = 'net.engagelab.mycommitment'

      AWS::S3::DEFAULT_HOST.replace 's3-us-west-2.amazonaws.com'
      AWS::S3::Base.establish_connection!(
          :access_key_id     => awskey,
          :secret_access_key => awssecret
      )

      s3media = AWS::S3::S3Object.delete media.s3id, bucket

      if s3media then
        if media.destroy then
          status 200
          return {"message" => "Image deleted"}.to_json
        else
          status 500
        end
      end
    end
  end
end

require_relative 'models/init'