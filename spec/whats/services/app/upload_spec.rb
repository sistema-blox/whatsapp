require 'spec_helper'

RSpec.describe App::RetrieveMedia do
  let(:client) { instance_double("Whats::Client") }
  let(:file) { 'file_content' }
  let(:upload_id) { '12345' }
  let(:content_type) { 'image/jpeg' }
  let(:upload) { described_class.new(client, file, upload_id, content_type) }

  describe '#initialize' do
    it 'initializes with a client, file, upload_id, and content_type' do
      expect(upload.client).to eq(client)
      expect(upload.file).to eq(file)
      expect(upload.content_type).to eq(content_type)
      expect(upload.path).to eq(App::RetrieveMedia::ENDPOINT % { upload_id: upload_id })
    end
  end

  describe '.call' do
    it 'creates an instance and calls #call' do
      expect(described_class).to receive(:new).with(client, file, upload_id, content_type).and_return(upload)
      expect(upload).to receive(:call)
      described_class.call(client: client, file: file, upload_id: upload_id, content_type: content_type)
    end
  end

  describe '#call' do
    before do
      allow(client).to receive(:request)
    end

    it 'sends a request to the client with correct parameters' do
      expect(client).to receive(:request).with(
        path: upload.path,
        payload: file,
        content_type: content_type,
        method: :post,
        overwrite_token_type: :oauth
      )
      upload.call
    end
  end
end
