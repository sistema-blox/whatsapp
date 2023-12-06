require 'spec_helper'

RSpec.describe Whats::Actions::UploadMedia do
  let(:client) { instance_double("Whats::Client") }
  let(:phone_number_id) { '123456789' }
  let(:file) { 'path/to/file.png' }
  let(:type) { 'image/png' }
  let(:upload_media) { described_class.new(client, phone_number_id, file, type) }

  describe '#initialize' do
    it 'initializes with a client, phone number id, file, and type' do
      expect(upload_media.client).to eq(client)
      expect(upload_media.file).to eq(file)
      expect(upload_media.type).to eq(type)
      expect(upload_media.path).to eq(Whats::Actions::UploadMedia::ENDPOINT % { phone_number_id: phone_number_id })
    end
  end

  describe '#call' do
    pending 'TODO: update this test' do
      let(:file_part) { instance_double("Faraday::FilePart") }
      let(:payload) {
        {
          file: file_part,
          type: type,
          messaging_product: "whatsapp"
        }
      }

      before do
        allow(Faraday::FilePart).to receive(:new).with(file, type).and_return(file_part)
        allow(client).to receive(:request)
      end

      it 'sends a request to the client with correct parameters' do
        expect(client).to receive(:request).with(
          path: upload_media.path,
          payload: payload,
          content_type: "multipart/form-data"
        )
        upload_media.call
      end
    end
  end
end
