module Whats
  module Actions
    class DownloadMedia
      attr_reader :media_url

      def initialize(media_url)
        @media_url = media_url
      end

      def call
        client.request(method: :get, overwrite_token_type: :bearer)
      end

      private

      def client
        @client ||= Whats::Client.new(url: media_url)
      end
    end
  end
end
