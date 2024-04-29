# frozen_string_literal: true

module Whats
  module Actions
    class SendMessage
      ENDPOINT = "/v17.0/%{phone_id}/messages"

      COMMON_PAYLOAD = {
        messaging_product: 'whatsapp',
        recipient_type: 'individual'
      }.freeze

      def initialize(client, wa_id, phone_id, type = 'text', body)
        @client = client
        @wa_id  = wa_id
        @body   = body
        @type   = type
        @path   = URI::DEFAULT_PARSER.escape(ENDPOINT % {phone_id: phone_id})
      end

      attr_reader :path

      def call
        client.request(path:, payload:)
      end

      private

      attr_reader :client, :wa_id, :type, :body

      def payload
        case type
        when 'text'
          COMMON_PAYLOAD.merge(
            to: wa_id,
            type: type,
            text: {
              body: body
            }
          )
        when 'interactive'
          COMMON_PAYLOAD.merge(
            to: wa_id,
            type: type,
            interactive: body
          )
        when 'template'
          COMMON_PAYLOAD.merge(
            to: wa_id,
            type: type,
            **template_payload
          )
        else
          raise Whats::Errors::RequestError.new("WhatsApp error: type should be 'text' or 'interactive'")
        end
      end

      def template_payload
        {
          template: body[:template],
          components: body[:components] 
        }.compact
      end
    end
  end
end

