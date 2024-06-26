# frozen_string_literal: true

require "whats/actions/check_contacts"
require "whats/actions/send_message"
require "whats/actions/mark_read"
require "whats/actions/business_profile"
require "whats/actions/upload_media"
require "whats/actions/get_media"
require "whats/actions/download_media"
require "whats/actions/templates/create"
require "whats/actions/templates/update"
require "whats/actions/templates/delete"

module Whats
  class Api
    def initialize
      @base_path = Whats.configuration.base_path
      @token = Whats.configuration.token
      @phone_id = Whats.configuration.phone_id
    end

    def check_contacts(numbers)
      Actions::CheckContacts.new(client, numbers).call
    end

    def check_contact(number)
      response = check_contacts([number])
      if response["errors"]
        raise Whats::Errors::RequestError.new("WhatsApp error.", response)
      end

      result = \
        response["contacts"].reduce({}) do |temp, hash|
          temp.merge(hash["input"] => hash)
        end

      result[number]
    end

    attr_reader :phone_id

    def send_message(to, type, body)
      Actions::SendMessage.new(client, to, phone_id, type, body).call
    end

    def mark_read(message_id)
      Actions::MarkRead.new(client, message_id, phone_id).call
    end

    def update_business_profile(payload)
      Actions::BusinessProfile.new(
        client:,
        from_phone_number_id: phone_id,
        payload:
      ).call
    end

    def get_business_profile
      Actions::BusinessProfile.new(
        client:,
        from_phone_number_id: phone_id,
        action: :get
      ).call
    end

    def upload_media(file_path, type)
      Actions::UploadMedia.new(client, phone_id, file_path, type).call
    end

    def get_media(media_id)
      Actions::GetMedia.new(client, media_id).call
    end

    def download_media(media_url)
      Actions::DownloadMedia.new(media_url).call
    end

    def create_template(payload)
      Actions::Templates::Create.new(client, payload).call
    end

    def update_template(template_id, payload)
      Actions::Templates::Update.new(client, template_id, payload).call
    end

    def delete_template(template_id)
      Actions::Templates::Delete.new(client, template_id).call
    end

    private

    attr_reader :base_path

    def client
      @client ||= Whats::Client.new
    end
  end
end
