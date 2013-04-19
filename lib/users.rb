require "faraday"
require "json"

module Users
  module_function

  CONN = Faraday.new(:url => Settings::API+"users")

  def fetch
    begin
      resp = CONN.get
    rescue Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed
      raise
    end

    Array(JSON.parse(resp.body)["reviewers"])
  end

  def create(api_key, name, email)
    begin
      resp = CONN.post do |req|
        req.body = {:api_key => api_key, :accountName => email, :name => name}.to_json
        puts req.body
      end
    rescue Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed
      return [{"error" => "Noe gikk galt!"}.to_json, nil]
    end
    res = JSON.parse(resp.body)
    return [res, nil] if resp.status != 201
    return [nil, res["reviewer"]]
  end

  def save
  end
end