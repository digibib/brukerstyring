require "faraday"
require "json"

module Sources
  module_function

  CONN = Faraday.new(:url => Settings::API+"sources")

  def fetch
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
    homepage = "ukjent" if homepage.empty?
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

  def update(uri, name, homepage)
    homepage = "ukjent" if homepage.empty?
    begin
      resp = CONN.put do |req|
        req.headers[:secret_session_key] = Settings::SECRET_SESSION_KEY
        req.body = {:uri => uri, :name => name, :homepage => homepage}.to_json
      end
    rescue Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed
      return {"error" => "Noe gikk galt!"}.to_json
    end
    resp.body
  end

  def delete(uri)
    begin
      resp = CONN.delete do |req|
        req.headers[:secret_session_key] = Settings::SECRET_SESSION_KEY
        req.body = {:uri => uri}.to_json
      end
    rescue Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed
      return {"error" => "Noe gikk galt!"}.to_json
    end
    resp.body
  end

  def key(uri)
    source = Cache.get(uri) {
      begin
        resp = CONN.get do |req|
          req.headers[:secret_session_key] = Settings::SECRET_SESSION_KEY
          req.body = {:uri => uri}.to_json
        end
      rescue Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed
        #
      end
      source = JSON.parse(resp.body)["source"]
      Cache.set(uri, source)
      source
    }
    source["api_key"]
  end
end