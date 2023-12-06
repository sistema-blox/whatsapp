module App
  class UploadSession
    attr_reader :client, :file_length, :file_type, :file_name

    ENDPOINT = "/v18.0/app/uploads/?file_length=%{file_length}&file_type=%{file_type}&file_name=%{file_name}"
    ACCEPTED_FILE_TYPES = ["image", "jpeg", "jpg", "png"]

    def initialize(client, file_length, file_type, file_name)
      @client = client
      @file_length = file_length
      @file_type = file_type
      @file_name = file_name
    end

    def self.call(client:, file_length:, file_type:, file_name:)
      new(client, file_length, file_type, file_name).call
    end

    def call
      client.request(path:) 
    end

    private

    def path
      raise ArgumentError, "file_length must be an Integer" unless file_length.instance_of?(Integer)
      raise ArgumentError, "file_name must be a String" unless file_name.instance_of?(String)
      raise ArgumentError, "file_type must be a String" unless file_type.instance_of?(String)

      unless (file_type.split("/").map(&:strip) & ACCEPTED_FILE_TYPES).count == 2
        raise ArgumentError, "file_type should be: image/jpeg, image/jpg or image/png"
      end

      URI::DEFAULT_PARSER.escape(ENDPOINT % { file_length: file_length, file_type: file_type, file_name: file_name })
    end
  end
end
