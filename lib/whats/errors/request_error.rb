# frozen_string_literal: true

module Whats
  module Errors
    class RequestError < StandardError
      def initialize(message, response = nil)
        detailed_message = format_error_message(message, response)
        
        super detailed_message
      end

      private

      def format_error_message(message, response)
        return message unless response && response["error"]

        response_error = response["error"]
        error_details = []

        error_details << message
        response_error.each { |key, value| error_details << "#{key}: #{value}" }
        
        error_details.join(" | ")
      end
    end
  end
end
