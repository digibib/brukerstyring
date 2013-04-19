require 'sinatra/base'
require 'torquebox'
require 'faraday'
require 'json'


require_relative "config/settings"
require_relative "lib/cache"
require_relative "lib/users"
require_relative "lib/sources"

class Brukerstyring < Sinatra::Base

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  use TorqueBox::Session::ServletStore

  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    [username, password] == [Settings::USERNAME, Settings::PASSWORD]
  end

  before do
    # nothing
  end

  get "/" do
    @sources = Sources.fetch

    users = Users.fetch
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

  post "/user" do
    api_key = Sources.key(params["uri"])
    puts api_key
    err, user = Users.create(api_key, params["name"], params["email"])
    if err
      status 400
      err["error"]
    else
      user.to_json
    end
  end

end