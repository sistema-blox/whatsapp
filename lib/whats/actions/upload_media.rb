module Whats
  module Actions
    class UploadMedia
      attr_reader :client, :file_path, :type, :path

      ENDPOINT = "/v18.0/%{phone_number_id}/media"

      def initialize(client, phone_number_id, file_path, type)
        @client = client
        @file_path = file_path
        @type = type
        @path = URI::DEFAULT_PARSER.escape(ENDPOINT % { phone_number_id: phone_number_id })
      end

      def call
        client.request(path:, payload:, content_type: "multipart/form-data")
      end

      private

      def payload
        {
          file: File.open(file_path),
          type:,
          messaging_product: "whatsapp"
        }
      end
    end
  end
end
