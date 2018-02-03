class FacebookService
  class << self
    def handle_message(sender_id, message)
      if text = message['text']
        reply = case text
        when /list all phone brands/
          phone_brands.join("\n")
        when /list all the phones made by (.*)/
          brand = $1
          phones = phones_by_brand(brand)

          if phones.count > 0
            phones.join("\n")
          else
            "There are no phones made by #{brand}"
          end
        when /what is the value of a (.*)/
          phone = $1
          matches = phone_matches(phone)

          matches.map { |phone| "#{phone['name']}: *R#{phone['value'].to_f/100}*" }
            .join("\n")
        else
          "I don't understand"
        end

        send_message(sender_id, reply) if reply
      end
    end

    def send_message(receiver_id, message)
      data = {
        recipient: {id: receiver_id},
        message:   {text: message}
      }

      HTTParty.post("https://graph.facebook.com/v2.6/me/messages",
        body:    data.to_json,
        query:   {access_token: page_access_token},
        headers: {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
    end

    private
    def page_access_token
      Settings.facebook.page_access_token
    end

    def phone_brands
      root_client.list_gadget_models.map{ |phone| phone['make'] }.uniq
    end

    def phones_by_brand(brand)
      brand_lowercase = brand.downcase
      root_client.list_gadget_models
        .select { |phone| phone['make'].downcase == brand_lowercase }
        .map{ |phone| phone['name'] }
    end

    def phone_matches(phone)
      phone_lowercase = phone.downcase
      root_client.list_gadget_models
        .select { |phone| phone['name'].downcase.include?(phone_lowercase) }
    end

    def root_client
      Root::Insurance::Client.new(Settings.root.app_id, Settings.root.app_secret)
    end
  end
end
