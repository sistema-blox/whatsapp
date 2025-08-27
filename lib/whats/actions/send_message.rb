# frozen_string_literal: true

module Whats
  module Actions
    class SendMessage
      ENDPOINT = "/v23.0/%{phone_id}/messages"

      COMMON_PAYLOAD = {
        messaging_product: 'whatsapp',
        recipient_type: 'individual'
      }.freeze

      PAYLOAD_TYPES = %w[text interactive template document].freeze

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
        unless PAYLOAD_TYPES.include?(type)
          raise Whats::Errors::RequestError.new("WhatsApp error: type not supported")
        end

        send("#{type}_payload")
      end

      def text_payload
        COMMON_PAYLOAD.merge(
          to: wa_id,
          type:,
          text: {
            body:
          }
        )
      end

      def interactive_payload
        COMMON_PAYLOAD.merge(
          to: wa_id,
          type:,
          interactive: body
        )
      end

      def template_payload
        COMMON_PAYLOAD.merge(
          to: wa_id,
          type:,
          template: body[:template],
          components: body[:components]
        ).compact
      end

      def document_payload
        COMMON_PAYLOAD.merge(
          to: wa_id,
          type:,
          document: body
        ) 
      end
    end
  end
end

