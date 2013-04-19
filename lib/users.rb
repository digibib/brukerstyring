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

  def save
  end
end