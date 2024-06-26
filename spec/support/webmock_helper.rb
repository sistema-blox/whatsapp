# frozen_string_literal: true

require_relative "fixture_helper"

module WebmockHelper
  include FixtureHelper

  BASE_PATH                   = "http://test.local"
  CHECK_CONTACTS_URL          = "#{BASE_PATH}#{Whats::Actions::CheckContacts::PATH}"
  SEND_MESSAGE_URL            = "#{BASE_PATH}#{Whats::Actions::SendMessage::ENDPOINT}"
  MARK_READ_URL               = "#{BASE_PATH}#{Whats::Actions::MarkRead::ENDPOINT}"
  MESSAGE_TEMPLATE_URL        = "#{BASE_PATH}#{Whats::Actions::Templates::Create::ENDPOINT}"
  UPDATE_MESSAGE_TEMPLATE_URL = "#{BASE_PATH}#{Whats::Actions::Templates::Update::ENDPOINT}"
  DELETE_MESSAGE_TEMPLATE_URL = "#{BASE_PATH}#{Whats::Actions::Templates::Delete::ENDPOINT}"

  def stub_check_contacts_with_valid_number(contact, wa_id)
    stub_default(
      CHECK_CONTACTS_URL,
      request_body: check_contacts_request(contact: contact),
      response_body: check_contacts_response(input: contact, wa_id: wa_id)
    )
  end

  def stub_check_contacts_with_valid_numbers(contacts, wa_ids)
    stub_default(
      CHECK_CONTACTS_URL,
      request_body: check_multiple_contacts_request(contacts: contacts),
      response_body: check_multiple_contacts_response(
        inputs: contacts, wa_ids: wa_ids
      )
    )
  end

  def stub_check_contacts_with_invalid_number(contact)
    stub_default(
      CHECK_CONTACTS_URL,
      request_body: check_contacts_request(contact: contact),
      response_body: check_contacts_response_invalid(input: contact)
    )
  end

  def stub_send_message_with_valid_response(phone_id, wa_id, body)
    url = generate_message_url(phone_id)

    stub_default(
      url,
      request_body: send_message_request(wa_id: wa_id, body: body),
      response_body: message_sent_response
    )
  end

  def stub_send_message_with_unknown_contact_response(phone_id, wa_id, body)
    url = generate_message_url(phone_id)

    stub_default(
      url,
      request_body: send_message_request(wa_id: wa_id, body: body),
      response_body: message_sent_with_unknown_contact_response
    )
  end

  def stub_send_message_with_empty_wa_id_response(phone_id, body)
    url = generate_message_url(phone_id)

    stub_default(
      url,
      request_body: send_message_request(wa_id: "", body: body),
      response_body: message_sent_with_empty_wa_id_response
    )
  end

  def stub_send_message_with_empty_body_response(phone_id, wa_id)
    url = generate_message_url(phone_id)

    stub_default(
      url,
      request_body: send_message_request(wa_id: wa_id, body: ""),
      response_body: message_sent_with_empty_body_response
    )
  end

  def stub_mark_read_with_valid_params(message_id, phone_id)
    url = URI::DEFAULT_PARSER.escape(MARK_READ_URL % {phone_id: phone_id})

    stub_default(
      url,
      request_body: mark_read_request(message_id),
      response_body: mark_read_response
    )
  end

  def stub_mark_read_with_invalid_params(message_id)
    url = URI::DEFAULT_PARSER.escape(MARK_READ_URL % {phone_id: phone_id})

    stub_default(
      url,
      request_body: mark_read_request(message_id),
      response_body: mark_read_invalid_response
    )
  end

  def stub_create_template_with_valid_params(payload)
    url = URI::DEFAULT_PARSER.escape(MESSAGE_TEMPLATE_URL % { waba_id: Whats.configuration.waba_id })

    stub_default(
      url,
      method: :post,
      request_body: payload.to_json,
      response_body: create_template_valid_response
    )
  end

  def stub_update_message_template(template_id, payload)
    url = URI::DEFAULT_PARSER.escape(UPDATE_MESSAGE_TEMPLATE_URL % { waba_id: Whats.configuration.waba_id, template_id: template_id })

    stub_default(
      url,
      method: :post,
      request_body: payload.to_json,
      response_body: update_template_valid_response
    )
  end

  def stub_delete_message_template(template_name)
    url = URI::DEFAULT_PARSER.escape(DELETE_MESSAGE_TEMPLATE_URL % { waba_id: Whats.configuration.waba_id, template_name: })

    stub_default(
      url,
      method: :delete,
      request_body: "",
      response_body: delete_template_valid_response
    )
  end

  def stub_default(url, method: :post, request_body:, response_body:, status: 200, headers: { "Content-Type" => "application/json" })
    stub = stub_request(method, url)
      .with(
        body: request_body,
        headers: headers
      )
      .to_return(
        body: response_body,
        status: status,
        headers: { "Content-Type" => "application/json" }
      )

    print_stub(stub) if ENV["PRINT_STUBS"] == "true"
  end

  def generate_message_url(phone_id)
    URI::DEFAULT_PARSER.escape(SEND_MESSAGE_URL % {phone_id: phone_id})
  end

  def print_stub(stub)
    puts "+ ------ STUB ------"
    puts "+ Request:  #{stub.request_pattern}"
    puts "+ Response: #{stub.response.body}"
    puts "+ ------------------"
  end
end