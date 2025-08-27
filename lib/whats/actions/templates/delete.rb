module Whats
  module Actions
    module Templates
      class Delete
        include ActiveModel::Validations

        attr_reader :client, :template_name

        ENDPOINT = "/v23.0/%{waba_id}/message_templates?name=%{template_name}"

        validates :template_name, presence: true

        def initialize(client, template_name)
          @client = client
          @template_name = template_name
        end

        def call
          raise StandardError.new("Invalid template data: #{errors.full_messages.join(', ')}") unless valid?

          client.request(path: path, method: :delete)
        rescue StandardError => e
          { error: e.message }
        end

        private

        def path
          format(ENDPOINT, waba_id: Whats.configuration.waba_id, template_name: template_name)
        end
      end
    end
  end
end
