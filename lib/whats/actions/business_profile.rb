require "whats/services/app/upload_session"
require "whats/services/app/upload"

module Whats
  module Actions
    class BusinessProfile
      attr_reader :client, :from_phone_number_id, :path, :payload

      ENDPOINT = "/v18.0/%{from_phone_number_id}/whatsapp_business_profile"
      ACCEPTED_PARAMS = [:websites, :address, :description, :email, :about, :profile_picture_handle]

      def initialize(client:, from_phone_number_id:, payload:)
        @client = client
        @from_phone_number_id = from_phone_number_id
        @path = URI::DEFAULT_PARSER.escape(ENDPOINT % { from_phone_number_id: from_phone_number_id })
        @payload = payload
      end

      def call
        client.request(path: path, payload: req_payload)
      end

      private

      def req_payload
        raise ArgumentError, "req_payload must be a Hash" unless payload.instance_of?(Hash)

        set_profile_picture_url if payload[:file].instance_of?(File)

        validate_parameters

        {
          messaging_product: "whatsapp",
        }.merge(payload)
      end

      def set_profile_picture_url
        file_length = payload[:file].size
        file_type = `file --mime-type -b #{payload[:file].path}`.chomp
        file_path = payload[:file].path
        file_name = file_path.split("/").last

        us_response = App::UploadSession.call(client: client, file_length: file_length, file_type: file_type, file_name: file_name)

        raise "Upload session response does not contain an id." if us_response["id"].nil?

        upload_response = App::Upload.call(client: client, file: File.binread(file_path), upload_id: us_response["id"], content_type: file_type)

        payload.delete(:file)

        raise "Upload response does not contain a handle." if upload_response["h"].nil?

        payload[:profile_picture_handle] = upload_response["h"]
      end

      def validate_parameters
        raise NotImplementedError, "Unsupported parameter(s) in payload: #{payload.keys - ACCEPTED_PARAMS}" unless payload.keys.all? { |k| ACCEPTED_PARAMS.include?(k) }

        websites = payload[:websites]
        address = payload[:address] || ""
        description = payload[:description] || ""
        email = payload[:email] || ""

        reg = /^http(s){0,1}:(\/){2}/
        email_reg = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
        common_website_error = "You must include the http:// or https:// portion of the URL."

        if websites.instance_of?(String)
          raise char_limit_error("Website", 256) if websites.size > 256
          raise common_website_error unless websites.match?(reg)
        end

        if websites.instance_of?(Array)
          raise "There is a maximum of 2 websites with a maximum of 256 characters each." if websites.size > 2

          websites.each do |website|
            raise char_limit_error("Website", 256) if website.size > 256
            raise common_website_error unless website.match?(reg)
          end
        end

        raise char_limit_error("Address", 256) if address.size > 256
        raise char_limit_error("Description", 512) if description.size > 512

        if !email.empty? && !email.match?(email_reg) || email.size > 128
          raise char_limit_error("The contact email address (in valid email format)", 128)
        end
      end

      def char_limit_error(param, size)
        "#{param} of the business. Character limit #{size}."
      end
    end
  end
end
