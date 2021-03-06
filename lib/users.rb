# encoding: UTF-8
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

  def create(api_key, name, email, active)
    begin
      resp = CONN.post do |req|
        req.body = {:api_key => api_key, :accountName => email,
                    :active => active, :name => name}.to_json
        puts req.body
      end
    rescue Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed
      return [{"error" => "Noe gikk galt!"}.to_json, nil]
    end
    res = JSON.parse(resp.body)
    return [res, nil] if resp.status != 201

    # Notify user of the created account
    Email.new_user(email, name)

    return [nil, res["reviewer"]]
  end

  def delete(api_key, uri)
    begin
      resp = CONN.delete do |req|
        req.body = {:api_key => api_key, :uri => uri}.to_json
        puts req.body
      end
    rescue Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed
      return [{"error" => "Noe gikk galt!"}.to_json, nil]
    end
    res = JSON.parse(resp.body)
    return [res, nil] if resp.status != 200
    return [nil, res]
  end

  def save(api_key, uri, name, email, new_password)
    r = {:api_key => api_key,
         :uri => uri, :accountName => email,
         :name => name}

    if new_password == "true"
      r[:password] = rand(36**8).to_s(36)
    end

    begin
      resp = CONN.put do |req|
        req.body = r.to_json
        puts req.body
      end
    rescue Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed
      return [{"error" => "Noe gikk galt!"}.to_json, nil]
    end
    res = JSON.parse(resp.body)
    return [res, nil] if resp.status != 200

    if new_password == "true"
      Email.new_password(email, name, r[:password])
    end

    return [nil, res]
  end

end
