# frozen_string_literal: true

module Whats
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end

  class Configuration
    attr_accessor :base_path, :token, :phone_id, :waba_id
  end
end
