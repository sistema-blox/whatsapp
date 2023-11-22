module Whats
  module Actions
    class BusinessProfile
      attr_reader :client, :from_phone_number_id, :path, :payload

      ENDPOINT = "/v18.0/%{from_phone_number_id}/whatsapp_business_profile"

      def initialize(client:, from_phone_number_id:, payload:)
        @client = client
        @from_phone_number_id = from_phone_number_id
        @path = URI::DEFAULT_PARSER.escape(ENDPOINT % { from_phone_number_id: from_phone_number_id })
        @payload = payload
      end

      def call
        client.request path, req_payload 
      end
      
      private

      def req_payload
        validate_parameters

        {
          messaging_product: "whatsapp",
        }.merge(payload)
      end

      def validate_parameters
        raise ArgumentError, "req_payload must be a Hash" unless payload.instance_of?(Hash)
        raise NotImplementedError, "Unsupported parameter(s) in payload: #{payload.keys - [:websites, :address, :description, :email]}" unless payload.keys.all? { |k| [:websites, :address, :description, :email].include?(k) }

        websites = payload[:websites]
        address = payload[:address] || ""
        description = payload[:description] || ""
        email = payload[:email] || ""

        reg = /^http(s){0,1}:(\/){2}/
        common_website_error = "You must include the http:// or https:// portion of the URL."
        
        if websites.instance_of?(String)
          return if websites.empty?

          raise common_website_error unless websites.match?(reg)
        end

        if websites.instance_of?(Array)
          raise "There is a maximum of 2 websites with a maximum of 256 characters each." if websites.size > 2

          websites.each do |website|
            raise common_website_error unless website.match?(reg)
          end
        end

        raise common_error % { param: "Address", size: 256 } if address.size > 256 
        raise common_error % { param: "Description", size: 512 } if description.size > 512
        raise common_error % { param: "The contact email address (in valid email format)", size: 128 } if email.size > 128
      end

      def common_error
        "%{param} of the business. Character limit %{size}."
      end
    end
  end
end
