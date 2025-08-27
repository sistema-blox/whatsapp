# frozen_string_literal: true

require "active_model"

module Whats
  module Actions
    module Templates
      class Create
        include ActiveModel::Validations

        attr_reader :client, :path
        attr_accessor :name, :category, :allow_category_change, :language, :components

        ENDPOINT = "/v23.0/%{waba_id}/message_templates"
        AVAILABLE_CATEGORIES = %w[AUTHENTICATION MARKETING UTILITY]
        AVAILABLE_LANGUAGE_CODES = %w[
          af sq ar az bn bg ca zh_CN zh_HK zh_TW hr cs da nl en en_GB en_US et fil fi fr ka de el gu ha he hi hu id ga it
          ja kn kk rw_RW ko ky_KG lo lv lt mk ms ml mr nb fa pl pt_BR pt_PT pa ro ru sr sk sl es es_AR es_ES es_MX sw sv
          ta te th tr uk ur uz vi zu
        ]

        validates :name, presence: true
        validates :category, presence: true, inclusion: { in: AVAILABLE_CATEGORIES }
        validates :allow_category_change, inclusion: { in: [true, false] }, allow_nil: true
        validates :language, presence: true, inclusion: { in: AVAILABLE_LANGUAGE_CODES }
        validates :components, presence: true, length: { minimum: 1 }

        def initialize(client, payload)
          @client = client
          @name = payload[:name]
          @category = payload[:category]
          @allow_category_change = payload[:allow_category_change]
          @language = payload[:language]
          @components = payload[:components]
        end

        def call
          raise StandardError.new("Invalid template data: #{errors.full_messages.join(', ')}") unless valid?

          client.request(path: path, payload: format_payload)
        rescue StandardError => e
          { error: e.message }
        end

        private

        def path
          format(ENDPOINT, waba_id: Whats.configuration.waba_id)
        end

        def format_payload
          {
            name:,
            category:,
            allow_category_change:,
            language:,
            components:
          }.compact
        end
      end
    end
  end
end