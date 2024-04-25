# frozen_string_literal: true

require "spec_helper"

RSpec.describe Whats::Actions::Templates::Delete do
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
  let(:template_name) { "template_name" }

  describe "#initialize" do
    describe "when the template_id is empty" do
      it "raises an error" do
        instance = described_class.new(client, "")

        expect(instance.valid?).to be_falsey
      end
    end

    describe "when the template_id is not empty" do
      it "does not raise an error" do
        instance = described_class.new(client, template_name)

        expect(instance.valid?).to be_truthy
      end
    end
  end

  describe "#call" do
    before do
      stub_delete_message_template(template_name)
    end

    it "returns a success response" do
      response = described_class.new(client, template_name).call

      expect(response["success"]).to be_truthy
    end
  end
end
