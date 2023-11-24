require 'spec_helper'

RSpec.describe Whats::Actions::BusinessProfile do
  let(:client) { instance_double("Whats::Client") }
  let(:from_phone_number_id) { '123456789' }
  let(:payload) { { websites: ['https://example.com'], address: '123 Main St', description: 'Description', email: 'email@example.com' } }
  let(:business_profile) { described_class.new(client: client, from_phone_number_id: from_phone_number_id, payload: payload) }

  describe '#initialize' do
    it 'initializes with a client, from_phone_number_id, and payload' do
      expect(business_profile.client).to eq(client)
      expect(business_profile.from_phone_number_id).to eq(from_phone_number_id)
      expect(business_profile.payload).to eq(payload)
    end
  end

  describe '#call' do
    before do
      allow(client).to receive(:request)
    end

    it 'sends a request to the client with correct parameters' do
      expect(client).to receive(:request).with(path: anything, payload: anything)
      business_profile.call
    end
  end

  describe 'validations and exceptions' do
    context 'when payload is not a hash' do
      let(:payload) { 'not a hash' }

      it 'raises an ArgumentError' do
        expect { business_profile.call }.to raise_error(ArgumentError, 'req_payload must be a Hash')
      end
    end

    context 'when payload contains unsupported parameters' do
      let(:payload) { { unsupported_param: 'value' } }

      it 'raises a NotImplementedError' do
        expect { business_profile.call }.to raise_error(NotImplementedError, /Unsupported parameter\(s\) in payload:/)
      end
    end

    context 'websites' do
      context 'when is not an array' do
        let(:payload) { { websites: 'not an array' } }

        it 'raises an ArgumentError' do
          expect { business_profile.call }.to raise_error(RuntimeError, 'You must include the http:// or https:// portion of the URL.')
        end
      end

      context 'when is an array with invalid format' do
        let(:payload) { { websites: ['example.com'] } }

        it 'raises an ArgumentError' do
          expect { business_profile.call }.to raise_error(RuntimeError, 'You must include the http:// or https:// portion of the URL.')
        end
      end

      context 'when is an array with more than 2 items' do
        let(:payload) { { websites: ['https://example.com', 'https://example2.com', 'https://example3.com'] } }

        it 'raises an RuntimeError' do
          expect { business_profile.call }.to raise_error(RuntimeError, 'There is a maximum of 2 websites with a maximum of 256 characters each.')
        end
      end

      context 'whan is larger than 256 characters' do
        let(:payload) { { websites: ['https://example.com' + 'a' * 257] } }

        it 'raises an RuntimeError' do
          expect { business_profile.call }.to raise_error(RuntimeError, 'Website of the business. Character limit 256.')
        end
      end
    end

    context 'address with more than 256 characters' do
      let(:payload) { { address: 'a' * 257 } }

      it 'raises an RuntimeError' do
        expect { business_profile.call }.to raise_error(RuntimeError, 'Address of the business. Character limit 256.')
      end
    end

    context 'description with more than 512 characters' do
      let(:payload) { { description: 'a' * 513 } }

      it 'raises an RuntimeError' do
        expect { business_profile.call }.to raise_error(RuntimeError, 'Description of the business. Character limit 512.')
      end
    end

    context 'email' do
      context 'when is a invalid' do
        let(:payload) { { email: 'not an email' } }

        it 'raises an RuntimeError' do
          expect { business_profile.call }.to raise_error(RuntimeError, 'The contact email address (in valid email format) of the business. Character limit 128.')
        end
      end

      context 'when is larger than 128 characters' do
        let(:payload) { { email: 'email@email.com' * 129 } }

        it 'raises an RuntimeError' do
          expect { business_profile.call }.to raise_error(RuntimeError, 'The contact email address (in valid email format) of the business. Character limit 128.')
        end
      end
    end
  end

  describe 'set_profile_picture_url' do
    context 'when a valid file is provided' do
      let(:tempfile) do
        file = Tempfile.new(['test-image', '.png'])
        file.write("\x89PNG\r\n\x1A\n\x00\x00\x00\rIHDR\x00\x00\x03\x20\x00\x00\x02\x58\x08\x06\x00\x00\x00\x15zz\xF4")
        file.rewind
        file
      end

      let(:payload) { { file: File.open(tempfile, 'rb') } }
      let(:file_length) { payload[:file].size }
      let(:file_type) { `file --mime-type -b #{payload[:file].path}`.chomp }
      let(:file_name) { payload[:file].path.split("/").last }

      it 'uploads the profile picture and sets the profile_picture_handle' do
        expect(client).to receive(:request).with(
          path: "/v18.0/app/uploads/?file_length=#{file_length}&file_type=#{file_type}&file_name=#{file_name}",
        ).and_return({"id"=> "123"}).at_most(1).times

        expect(client).to receive(:request).with(
          path: "/v18.0/123",
          payload: File.binread(payload[:file]),
          content_type: file_type,
          method: :post,
          overwrite_token_type: :oauth
        ).and_return({"h"=> "abcdef123456"}).at_most(1).times

        expect(client).to receive(:request).with(
          path: "/v18.0/123456789/whatsapp_business_profile",
          payload: {
            messaging_product: "whatsapp",
            profile_picture_handle: "abcdef123456"
          }
        ).at_most(1).times

        business_profile.call

        expect(business_profile.payload[:profile_picture_handle]).to eq("abcdef123456")
      end
    end

    context 'when no file is provided' do
      before do
        allow(client).to receive(:request) # Stub the request method
        # Stub the request method
      end

      it 'does not make any upload requests' do
        expect(App::UploadSession).not_to receive(:call)
        expect(App::Upload).not_to receive(:call)

        business_profile.call
      end
    end
  end
end
