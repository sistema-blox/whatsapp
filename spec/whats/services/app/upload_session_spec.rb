require 'spec_helper'

RSpec.describe App::UploadSession do
  let(:client) { instance_double("Whats::Client") }
  let(:file_length) { 1024 }
  let(:file_type) { 'image/jpeg' }
  let(:file_name) { 'test.jpg' }
  let(:upload_session) { described_class.new(client, file_length, file_type, file_name) }

  describe '#initialize' do
    it 'initializes with client, file_length, file_type, and file_name' do
      expect(upload_session.client).to eq(client)
      expect(upload_session.file_length).to eq(file_length)
      expect(upload_session.file_type).to eq(file_type)
      expect(upload_session.file_name).to eq(file_name)
    end
  end

  describe '.call' do
    it 'creates an instance and calls #call' do
      expect(described_class).to receive(:new).with(client, file_length, file_type, file_name).and_return(upload_session)
      expect(upload_session).to receive(:call)
      described_class.call(client: client, file_length: file_length, file_type: file_type, file_name: file_name)
    end
  end

  describe '#call' do
    before do
      allow(client).to receive(:request)
    end

    it 'sends a request to the client with correct path' do
      expect(client).to receive(:request).with(path: anything)
      upload_session.call
    end
  end

  describe 'validations' do
    context 'when file_length is not an integer' do
      let(:file_length) { 'invalid_length' }
      let(:upload_session) { described_class.new(client, file_length, file_type, file_name) }

      it 'raises an ArgumentError' do
        expect { upload_session.call }.to raise_error(ArgumentError, 'file_length must be an Integer')
      end
    end

    context 'when file_type is not a string' do
      let(:file_type) { 123 }
      let(:upload_session) { described_class.new(client, file_length, file_type, file_name) }

      it 'raises an ArgumentError' do
        expect { upload_session.call }.to raise_error(ArgumentError, 'file_type must be a String')
      end
    end

    context 'when file_name is not a string' do
      let(:file_name) { 123 }
      let(:upload_session) { described_class.new(client, file_length, file_type, file_name) }

      it 'raises an ArgumentError' do
        expect { upload_session.call }.to raise_error(ArgumentError, 'file_name must be a String')
      end
    end
  end
end
