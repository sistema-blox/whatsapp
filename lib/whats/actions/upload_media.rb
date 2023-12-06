module Whats
  module Actions
    class UploadMedia
      attr_reader :client, :file, :type, :path

      ENDPOINT = "/v18.0/%{phone_number_id}/media"

      def initialize(client, phone_number_id, file, type)
        @client = client
        @file = file
        @type = type
        @path = URI::DEFAULT_PARSER.escape(ENDPOINT % { phone_number_id: phone_number_id })
      end

      def call
        client.request(path:, payload:, content_type: "multipart/form-data")
      end

      private

      def payload
        {
          file:,
          type:,
          messaging_product: "whatsapp"
        }
      end
    end
  end
end
