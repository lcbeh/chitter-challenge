
ENV["RACK_ENV"] ||= "development"

require 'sinatra/base'
require 'sinatra/flash'

require_relative 'data_mapper_setup'

class Chitter < Sinatra::Base
enable :sessions
set :session_secret, 'super secret'
register Sinatra::Flash
use Rack::MethodOverride

  get '/' do
    erb :index
  end

  get '/user/new' do
    @user = User.new
    erb :new_user
  end

  post '/users' do
    @user = User.create(name: params[:name], email: params[:email], user_name: params[:user_name], password: params[:password], password_confirmation: params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      redirect '/messages'
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :new_user
    end
  end

  get '/sessions/new' do
    erb :'sessions/new'
  end

  post '/sessions' do
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      redirect to '/messages'
    else
      flash.now[:errors] = [ "The email or password is incorrect"]
      erb :'sessions/new'
    end
  end

  get '/messages' do
    @messages = Message.all
    erb :messages
  end

  post '/messages' do
    Message.create(title: params[:title], content: params[:content])
    redirect '/messages'
  end

  get '/messages/new' do
    erb :new_message
  end

  delete '/sessions' do
    session[:user_id] = nil
    flash.keep[:notice] = 'Have a nice day!'
    redirect '/'
  end

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id])
    end
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
