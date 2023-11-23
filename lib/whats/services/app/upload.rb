module App
  class Upload
    attr_reader :file, :client, :path, :content_type

   ENDPOINT = "/v18.0/%{upload_id}"

    def initialize(client, file, upload_id, content_type)
      @client = client
      @file = file
      @content_type = content_type
      @path = URI::DEFAULT_PARSER.escape(ENDPOINT % { upload_id: upload_id })
    end

    def self.call(client:, file:, upload_id:, content_type:)
      new(client, file, upload_id, content_type).call
    end

    def call
      client.request path, file, content_type, :post, :oauth
    end
  end
end
