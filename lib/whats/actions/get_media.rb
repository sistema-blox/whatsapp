module Whats
  module Actions
    class GetMedia
      attr_reader :client, :path

      ENDPOINT = "/v23.0/%{media_id}"

      def initialize(client, media_id)
        @client = client
        @path   = URI::DEFAULT_PARSER.escape(ENDPOINT % { media_id: })
      end

      def call
        client.request(path: path, method: :get)
      end
    end
  end
end
