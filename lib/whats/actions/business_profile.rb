require "whats/services/app/upload_session"
require "whats/services/app/retrieve_media"

module Whats
  module Actions
    class BusinessProfile
      attr_reader :client, :from_phone_number_id, :path, :payload, :action

      ENDPOINT = "/v18.0/%{from_phone_number_id}/whatsapp_business_profile"
      ACCEPTED_PARAMS = [:websites, :address, :description, :email, :about, :profile_picture_handle]
      HTTP_REGEX = /^http(s){0,1}:(\/){2}/
      EMAIL_REGEX = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
      ACTIONS = [:update, :get]

      def initialize(client:, from_phone_number_id:, payload: nil, action: :update)
        @client = client
        @from_phone_number_id = from_phone_number_id
        @path = URI::DEFAULT_PARSER.escape(ENDPOINT % { from_phone_number_id: from_phone_number_id })
        @payload = generate_payload(payload) if action == :update
        @action = action
      end

      def call
        raise ArgumentError, "Unsupported action: #{action}" unless ACTIONS.include?(action)

        send("#{action}_business_profile")
      end

      private

      def path

      end

      def get_business_profile
        perform_request!(method: :get)
      end

      def update_business_profile
        set_profile_picture_url if payload[:file].instance_of?(File)

        perform_request!(payload:)
      end

      def perform_request!(aditional_params = {})
        client.request(path:, **aditional_params)
      end

      def generate_payload(req_payload)
        raise ArgumentError, "req_payload must be a Hash" unless req_payload.instance_of?(Hash)

        validate_parameters(req_payload)

        {
          messaging_product: "whatsapp",
        }.merge(req_payload)
      end

      def set_profile_picture_url
        file_length = payload[:file].size
        file_type = `file --mime-type -b #{payload[:file].path}`.chomp
        file_path = payload[:file].path
        file_name = file_path.split("/").last

        us_response = App::UploadSession.call(client:, file_length:, file_type:, file_name:)

        raise "Upload session response does not contain an id." if us_response["id"].nil?

        upload_response = App::RetrieveMedia.call(client: client, file: File.binread(file_path), upload_id: us_response["id"], content_type: file_type)

        payload.delete(:file)

        raise "Upload response does not contain a handle." if upload_response["h"].nil?

        payload[:profile_picture_handle] = upload_response["h"]
      end

      def validate_parameters(req_payload)
        raise NotImplementedError, "Unsupported parameter(s) in payload: #{req_payload.keys - ACCEPTED_PARAMS}" unless req_payload.keys.all? { |k| ACCEPTED_PARAMS.include?(k) }

        websites = req_payload[:websites]
        address = req_payload[:address] || ""
        description = req_payload[:description] || ""
        email = req_payload[:email] || ""

        if websites.instance_of?(String)
          raise char_limit_error("Website", 256) if websites.size > 256
          raise website_error unless websites.match?(HTTP_REGEX)
        end

        if websites.instance_of?(Array)
          raise "There is a maximum of 2 websites with a maximum of 256 characters each." if websites.size > 2

          websites.each do |website|
            raise char_limit_error("Website", 256) if website.size > 256
            raise website_error unless website.match?(HTTP_REGEX)
          end
        end

        raise char_limit_error("Address", 256) if address.size > 256
        raise char_limit_error("Description", 512) if description.size > 512

        if !email.empty? && !email.match?(EMAIL_REGEX) || email.size > 128
          raise char_limit_error("The contact email address (in valid email format)", 128)
        end
      end

      def website_error
        "You must include the http:// or https:// portion of the URL."
      end

      def char_limit_error(param, size)
        "#{param} of the business. Character limit #{size}."
      end
    end
  end
end
