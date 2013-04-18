require 'sinatra/base'
require 'torquebox'

require_relative "config/settings"
require_relative "lib/users"
require_relative "lib/sources"

class Brukerstyring < Sinatra::Base

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    [username, password] == [Settings::USERNAME, Settings::PASSWORD]
  end

  get "/" do
    @sources = Sources.load
    users = Users.load
    @sources.map { |s| s["users"] = users.group_by { |u| u["accountServiceHomepage"]}[s["uri"]] }

    erb :index
  end

  post "/source" do
    puts params
    Sources.create(params["name"], params["homepage"])
  end

  put "/source" do
    Sources.update(params["uri"], params["name"], params["homepage"])
  end

  delete "/source" do
    Sources.delete(params["uri"])
  end

end