require 'sinatra/base'
require 'torquebox'
require 'faraday'
require 'json'

require "./config/settings.rb"

module Sources
  module_function

  CONN = Faraday.new(:url => Settings::API+"sources")

  def load
    begin
      resp = CONN.get do |req|
        req.headers[:secret_session_key] = Settings::SECRET_SESSION_KEY
      end
    rescue Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed
      raise
    end

    Array(JSON.parse(resp.body)["sources"])
  end

  def save
    puts "save"
  end

  def create(name, homepage)
    begin
      resp = CONN.post do |req|
        req.headers[:secret_session_key] = Settings::SECRET_SESSION_KEY
        req.body = {:name => name, :homepage => homepage}.to_json
      end
    rescue Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed
      return {"error" => "Noe gikk galt!"}.to_json
    end
    resp.body
  end
end

module Users
  module_function

  CONN = Faraday.new(:url => Settings::API+"users")

  def load
    begin
      resp = CONN.get
    rescue Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed
      raise
    end

    Array(JSON.parse(resp.body)["reviewers"])
  end

  def save
  end
end

class Brukerstyring < Sinatra::Base

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    [username, password] == [Settings::USERNAME, settings::PASSWORD]
  end

  get "/" do

    @sources = Sources.load
    users = Users.load
    @sources.map { |s| s["users"] = users.group_by { |u| u["accountServiceHomepage"]}[s["uri"]] }

    erb :index
  end

  post "/source" do
    Sources.create(params["name"], params["homepage"])
  end

end