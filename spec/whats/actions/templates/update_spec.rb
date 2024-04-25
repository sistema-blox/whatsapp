# frozen_string_literal: true

require "spec_helper"

RSpec.describe Whats::Actions::Templates::Update do
  include WebmockHelper

  before do
    Whats.configure do |config|
      config.base_path = WebmockHelper::BASE_PATH
      config.phone_id = "9999999999999"
      config.token = "toooo.kkkkk.eeeen"
      config.waba_id = "5511944442222"
    end
  end

  let(:client) { Whats::Client.new }
  let(:template_id) { "123456789" }
  let(:payload) { 
    { 
      category: "MARKETING",
      components: [
        {
          type: "TEXT",
          text: "Hello, world!"
        }
      ] 
    } 
  }

  describe "#initialize" do
    it "does not accept invalid category" do
      payload[:category] = "INVALID"
      instance = described_class.new(client, template_id, payload)

      expect(instance.valid?).to be_falsey
    end

    it "does not accept empty components" do
      payload[:components] = []
      instance = described_class.new(client, template_id, payload)

      expect(instance.valid?).to be_falsey
    end
  end

  describe "#call" do
    let(:valid_response) { { "success" => true } }

    before do
      stub_update_message_template(template_id, payload)
    end

    it "returns error message when invalid" do
      payload[:category] = "INVALID"
      instance = described_class.new(client, template_id, payload)

      expect(instance.call).to eq({ error: "Invalid template data: Category is not included in the list" })
    end

    it "send request to update template" do
      instance = described_class.new(client, template_id, payload)

      expect(instance.call).to eq(valid_response)
    end
  end
end
