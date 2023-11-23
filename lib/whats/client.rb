# frozen_string_literal: true
# en_string_literal: true

require "whats/actions/login"

module Whats
  class Client
    attr_reader :base_path, :token, :token_type, :payload, :content_type, :full_path

    METHODS = [:get, :post]
    AVAILABLE_TOKEN_TYPES = [:basic, :bearer, :oauth]

    def initialize(token = nil, token_type = :bearer)
      @base_path = Whats.configuration.base_path
      @token = token || login.token
      @token_type = token_type
    end

    def request(path, payload = nil, content_type = "application/json", method = :post, overwrite_token_type = nil)
      raise ArgumentError, 'Invalid method' unless METHODS.include?(method)
      
      unless overwrite_token_type.nil?
        raise ArgumentError, 'Invalid token type' unless AVAILABLE_TOKEN_TYPES.include?(overwrite_token_type)

        @token_type = overwrite_token_type
      end

      @payload = payload
      @content_type = content_type
      @full_path = "#{base_path}#{path}"
     
      response = method == :post ? post : get
       
      body = JSON.parse(response.body)

      raise Whats::Errors::RequestError.new("API request error.", body) unless response.success?

      body
    end

    private

    def client
      @client = Faraday.new(url: full_path, headers: headers)
    end

    def post
      return client.post { |req| req.body = body(payload) } unless payload.nil?

      client.post
    end

    def get
      client.get
    end

    def token_name
      case token_type
      when :basic
        "Basic"
      when :bearer
        "Bearer"
      when :oauth
        "OAuth"
      end
    end

    def login
      Whats::Actions::Login.new
    end

    def headers
      {
        "Authorization" => "#{token_name} #{token}",
        "Content-Type" => content_type,
      }
    end

    def body(payload)
      return payload if content_type.include?("image/png")
      
      payload && payload.to_json
    end
  end
end
