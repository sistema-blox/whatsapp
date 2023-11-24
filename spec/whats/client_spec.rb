# frozen_string_literal: true

require "spec_helper"

RSpec.describe Whats::Client do
  subject(:client) { described_class.new double(token: "key") }

  let(:base_path) { WebmockHelper::BASE_PATH }

  describe "#request" do
    let(:path) { "/path" }
    let(:full_path) { "#{base_path}#{path}" }
    let(:payload) { { param: 123 } }
    let(:payload_json) { { param: 123 }.to_json }
    let(:response) { { key: "value" }.to_json }

    context "with valid params" do
      before do
        Whats.configure { |c| c.base_path = base_path }
        stub_request(:post, full_path)
          .with(
            body: payload_json,
            headers: { "Content-Type" => "application/json" }
          )
          .to_return(status: 200, body: response)
      end

      it "executes a POST request properly" do
        client.request(path: "/path", payload:)

        expect(WebMock)
          .to have_requested(:post, full_path)
          .with(
            body: payload_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns the response represented in hash" do
        result = client.request(path: "/path", payload:)

        expect(result).to eq("key" => "value")
      end
    end

    context "exceptions" do
      it "raises for unsupported methods" do
        expect { client.request(path: "/path", method: :put) }.to raise_error ArgumentError
      end

      it "raises for unsupported token types" do
        expect { client.request(path: "/path", overwrite_token_type: :invalid) }.to raise_error ArgumentError
      end
    end

    context 'when the API response is unsuccessful' do
      before do
        allow_any_instance_of(Faraday::Connection).to receive(:post)
          .and_return(double('response', success?: false, body: '{"error": {"message":"some_error"}}'))
      end

      it 'raises a RequestError' do
        expect { client.request(path: '/test') }
          .to raise_error(Whats::Errors::RequestError, "API request error. | message: some_error")
      end
    end
  end
end
