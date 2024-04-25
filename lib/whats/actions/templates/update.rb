# frozen_string_literal: true

require "active_model"

module Whats
  module Actions
    module Templates
      class Update
        include ActiveModel::Validations

        attr_accessor :category, :components
        attr_reader :client, :path

        ENDPOINT = "/v17.0/%{template_id}"

        validates :category, inclusion: { in: Create::AVAILABLE_CATEGORIES }, allow_nil: true
        validates :components, length: { minimum: 1 }, allow_nil: true

        def initialize(client, template_id, payload)
          @client = client
          @path = format(ENDPOINT, template_id: template_id)
          @category = payload[:category]
          @components = payload[:components]
        end

        def call
          raise StandardError.new("Invalid template data: #{errors.full_messages.join(', ')}") unless valid?

          client.request(path: path, payload: format_payload)
        rescue StandardError => e
          { error: e.message }
        end

        private

        def format_payload
          {
            category:,
            components:
          }.compact
        end
      end
    end
  end
end