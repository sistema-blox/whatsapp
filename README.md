
# WhatsApp
[![Build Status](https://travis-ci.org/getninjas/whatsapp.svg?branch=master)](https://travis-ci.org/getninjas/whatsapp)
[![Gem Version](https://badge.fury.io/rb/whatsapp.svg)](https://badge.fury.io/rb/whatsapp)

A ruby interface to WhatsApp Enterprise API, providing easy access to send and receive messages, manage profiles, and more via the WhatsApp Business API.

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
  - [Setting up a WhatsApp Business API Client](#setting-up-a-whatsapp-business-api-client)
  - [Sending Messages](#sending-messages)
  - [Checking Contacts](#checking-contacts)
  - [Marking Messages as Read](#marking-messages-as-read)
  - [Profile Management](#profile-management)
  - [Get Media](#get-media)
  - [Receiving Messages](#receiving-messages)
- [Tests](#tests)

## Installation

### Via Gemfile

Add this line to your application's Gemfile:

```ruby
gem 'whatsapp', github: 'sistema-blox/whatsapp'
```

And then execute:

```bash
bundle install
```

### Manual Installation

Alternatively, you can install it yourself via:

```bash
gem install whatsapp
```

## Usage

### Setting up a WhatsApp Business API Client

Before using the gem, ensure you have:
- A Facebook Business Manager account.
- A verified business.
- A WhatsApp business account.

For more details, visit: [WhatsApp Business API Setup](https://developers.facebook.com/docs/whatsapp/cloud-api/get-started).

#### Configuration

```ruby
Whats.configure do |config|
  config.base_path = "https://example.test"
  config.phone_id = "your phone id"
  config.token = "your token"
end

whats = Whats::Api.new
```

### Sending Messages

#### Text Message

```ruby
whats.send_message("5511942424242", "text", "Message goes here.")
```

#### Template Message

For more complex messages like templates, see [WhatsApp Message Templates](https://developers.facebook.com/docs/messenger-platform/send-messages/templates).

```ruby
# Example of sending a template message
body = {
  "type": "list",
  "header": {
   "type": "text",
   "text": "title"
  },
  "body": {
   "text": "body"
  },
  "action": {
   "button": "button title",
   "sections": [
    {
     "title": "section title",
     "rows": [
      {
       "id": "1",
       "title": "button 1"
      },
      {
       "id": "2",
       "title": "button 2"
      },
      ...
     ]
    }
   ]
  }
}

whats.send_message("5511942424242", "interactive", body)
```

### Checking Contacts

For checking contact details:

```ruby
whats.check_contacts(["+5511942424242"])
```

### Marking Messages as Read

To mark a message as read:

```ruby
whats.mark_read("message_id")
```

### Profile Management

Update your business profile using:

```ruby
whats.update_business_profile(
  about: "<profile-about-text>",                           # The business's **About** text. This text appears in the business's profile, beneath its profile image, phone number, and contact buttons.
  address: "<business-address>",                           # Address of the business. Character limit 256.
  description: "<business-description>",                   # Description of the business. Character limit 512.
  email: "<business-email>",                               # The contact email address (in valid email format) of the business. Character limit 128.
  file: "<file>",                                          # Desired image for profile picture, it must be 1024x1024.
  websites: ["<https://website-1>", "<https://website-2>"] # The URLs associated with the business. For instance, a website, Facebook Page, or Instagram. You must include the http:// or https:// portion of the URL. There is a maximum of 2 websites with a maximum of 256 characters each.
)
```

### Get Media
Sometimes we receive medias from our customers, to get this media you need:

- Send your media_id to get_media action
  ```ruby
   whats.get_media(123)
  ```
  Your response will be like this:
  ```ruby
   {
    "url"=>"https://lookaside.fbsbx.com/whatsapp_business/attachments/?mid=123&ext=123&hash=123-456",
    "mime_type"=>"audio/ogg",           
    "sha256"=>"sha256",
    "file_size"=>7645,                  
    "id"=>"123",           
    "messaging_product"=>"whatsapp"
   }
  ```
- Send media_url to download_media action
  ```ruby
    # based in our last example
    whats.download_media("https://lookaside.fbsbx.com/whatsapp_business/attachments/?mid=123&ext=123&hash=123-456")
  ```
  now you have a file called `media.ogg`

### Receiving Messages

To receive messages, configure a webhook as explained in the [WhatsApp documentation](https://developers.facebook.com/docs/whatsapp/sample-app-endpoints#cloud-api-sample-app-endpoint).

## Tests

### Running Tests

Execute tests using:

```shell
rspec
```

### Debugging Specs

To print all stubs:

```shell
PRINT_STUBS=true rspec
```
