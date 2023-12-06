# frozen_string_literal: true
# en_string_literal: true

module Whats
  class Client
    attr_reader :base_path, :content_type, :full_path, :http_client, :payload, :token, :token_type

    METHODS = [:get, :post]
    AVAILABLE_TOKEN_TYPES = [:basic, :bearer, :oauth]

    def initialize(token_type: :bearer, url: nil)
      @base_path = url || Whats.configuration.base_path
      @token = Whats.configuration.token
      @token_type = token_type
    end

    def request(path: "/", payload: nil, content_type: "application/json", method: :post, overwrite_token_type: nil)
      validate_method_and_token_type!(method, overwrite_token_type)

      setup_request_details(path, payload, content_type)

      response = send_request(method)
      handle_response(response)
    end

    private

    def validate_method_and_token_type!(method, overwrite_token_type)
      validate_http_method!(method)
      validate_and_set_token_type!(overwrite_token_type) unless overwrite_token_type.nil?
    end

    def validate_http_method!(method)
      raise ArgumentError, 'Invalid method' unless METHODS.include?(method)
    end

    def validate_and_set_token_type!(overwrite_token_type)
      raise ArgumentError, 'Invalid token type' unless AVAILABLE_TOKEN_TYPES.include?(overwrite_token_type)

      @token_type = overwrite_token_type
    end

    def setup_request_details(path, payload, content_type)
      @payload = payload
      @content_type = content_type
      @full_path = URI("#{base_path}#{path}")

      create_http_client
    end

    def create_http_client
      uri = URI.parse(full_path)
      @http_client = Net::HTTP.new(uri.host, uri.port)
      @http_client.use_ssl = (uri.scheme == "https")
    end

    def headers
      {
        "Authorization" => "#{authorization_token}",
        "Content-Type" => content_type
      }
    end

    def authorization_token
      case token_type
      when :basic
        "Basic #{token}"
      when :bearer
        "Bearer #{token}"
      when :oauth
        "OAuth #{token}"
      else
        raise ArgumentError, 'Invalid token type'
      end
    end

    def send_request(method)
      method == :post ? send_post_request : send_get_request
    end

    def send_post_request
      request = Net::HTTP::Post.new(full_path, headers)
      request.body = formatted_body if payload

      http_client.request(request)
    end

    def send_get_request
      request = Net::HTTP::Get.new(full_path, headers)
      http_client.request(request)
    end

    def formatted_body
      return payload.to_json if content_type.include?("application/json")

      payload
    end

    def handle_response(response)
      unless response.is_a?(Net::HTTPSuccess)
        err = response.content_type == "application/json" ? response.body : ""

        raise Whats::Errors::RequestError.new("API request error.", err)
      end

      parse_response(response)
    end

    def parse_response(response)
      content_type = response.content_type

      if content_type.include?('application/json')
        parse_json_response(response)
      elsif content_type.include?('audio/') || content_type.include?('video/') || content_type.include?('image/')
        download_media(response, content_type)
      else
        response.body
      end
    end

    def parse_json_response(response)
      begin
        JSON.parse(response.body)
      rescue JSON::ParserError => e
        raise Whats::Errors::ParseError, "JSON parsing error: #{e.message}"
      end
    end

    def download_media(response, content_type)
      extension = determine_file_extension(content_type)
      filename = "media.#{extension}"

      File.open(filename, "wb") { |file| file.write(response.body) }

      filename
    end

    def determine_file_extension(content_type)
      # This method should map content types to file extensions
      # For simplicity, here's a basic mapping for common types
      case content_type
      when /audio\/(\w+)/
        $1
      when /video\/(\w+)/
        $1
      when /image\/(\w+)/
        $1
      else
        'bin' # default binary extension
      end
    end
  end
end
