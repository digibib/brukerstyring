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

  get "/" do

    @sources = Sources.load
    users = Users.load
    @sources.map { |s| s["users"] = users.group_by { |u| u["accountServiceHomepage"]}[s["uri"]] }

    erb :index
  end

end