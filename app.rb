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
    puts params
    api_key = Sources.key(params["uri"])
    err, user = Users.create(api_key, params["name"], params["email"], params["active"])
    halt 400, err["error"].to_s if err
    "<tr class='bruker'><td class='epost'><input class='user-uri' type='hidden' value='#{user['uri']}'><input class='epost' type='text' value='#{user['accountName']}'></td><td class='navn'><input type='text' value='#{user['name']}'></td><td class='aktivert'><input type='checkbox' #{'checked="checked"' unless user['status']}></td><td class='endre'><button>lagre</button></td><td class='slett'><button class='delete-user'>slett</button></td><td class='info'></td></tr>"
  end

  put "/user" do

  end

  delete "/user" do
    puts params
    api_key = Sources.key(params["source_uri"])
    err, ok = Users.delete(api_key, params["user_uri"])
    halt 400, err["error"].to_s if err
    ok.to_json
  end


end