# frozen_string_literal: true

require "spec_helper"

RSpec.describe Whats::Actions::Templates::Create do
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
  let(:payload) do
    {
      name: "Template Name",
      category: "MARKETING",
      language: "pt_BR",
      allow_category_change: true,
      components: [
        {
          type: "BODY",
          text: "Body text"
        }
      ]
    }
  end

  describe "#initialize" do
    describe "when the payload is empty" do
      it "raises an error" do
        instance = described_class.new(client, {})

        expect(instance.valid?).to be_falsey
      end
    end

    describe "when does not have name attribute on payload" do
      it "raises an error" do
        instance = described_class.new(client, payload.except(:name))

        expect(instance.valid?).to be_falsey
        expect(instance.errors[:name]).to include("can't be blank")
      end
    end

    describe "when does not have category attribute on payload" do
      it "raises an error" do
        instance = described_class.new(client, payload.except(:category))

        expect(instance.valid?).to be_falsey
        expect(instance.errors[:category]).to include("can't be blank")
      end
    end

    describe "when does not have category with an invalid string" do
      it "raises an error" do
        instance = described_class.new(client, payload.merge(category: "INVALID"))

        expect(instance.valid?).to be_falsey
        expect(instance.errors[:category]).to include("is not included in the list")
      end
    end

    describe "when does not have language attribute on payload" do
      it "raises an error" do
        instance = described_class.new(client, payload.except(:language))

        expect(instance.valid?).to be_falsey
        expect(instance.errors[:language]).to include("can't be blank")
      end
    end

    describe "when does not have language with an invalid string" do
      it "raises an error" do
        instance = described_class.new(client, payload.merge(language: "INVALID"))

        expect(instance.valid?).to be_falsey
        expect(instance.errors[:language]).to include("is not included in the list")
      end
    end

    describe "when does not have components attribute on payload" do
      it "raises an error" do
        instance = described_class.new(client, payload.except(:components))

        expect(instance.valid?).to be_falsey
        expect(instance.errors[:components]).to include("can't be blank")
      end
    end

    describe "when does not have components with an empty array" do
      it "raises an error" do
        instance = described_class.new(client, payload.merge(components: []))

        expect(instance.valid?).to be_falsey
        expect(instance.errors[:components]).to include("is too short (minimum is 1 character)")
      end
    end

    describe "when the payload is valid" do
      it "creates an instance" do
        instance = described_class.new(client, payload)

        expect(instance.valid?).to be_truthy
      end
    end
  end

  describe "#call" do
    describe "when the instance is invalid" do
      it "raises an error" do
        instance = described_class.new(client, payload.except(:name))

        expect(instance.valid?).to be_falsey
        expect(instance.call).to eq({ error: "Invalid template data: Name can't be blank" })
      end
    end

    describe "when the instance is valid" do
      before do
        stub_create_template_with_valid_params(payload)
      end

      it "returns the response" do
        instance = described_class.new(client, payload)
        response = instance.call

        expect(response[:error]).to be_nil
        expect(response.keys).to include("id", "status", "category")
      end
    end
  end
end
