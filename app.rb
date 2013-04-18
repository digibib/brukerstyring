require 'sinatra/base'
require 'torquebox'

class Brukerstyring < Sinatra::Base

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  get "/" do
    erb :index
  end

end