require 'root'
require 'root/insurance'

module SlackInsureBot
  module Commands
    class Price < SlackRubyBot::Commands::Base
      command 'what is the value of a' do |client, data, match|
        action = "what is the value of a "

        chosen_phone = if data.text.index(action)
          n = data.text.index(action)
          data.text[n..-1]
        else
          data.text
        end

        chosen_phone.slice!(action)

        root_client = Root::Insurance::Client.new(Settings.root.app_id, Settings.root.app_secret)
        phones = root_client.list_gadget_models

        filtered_phones = phones.select do |phone|
          "#{phone['make']} #{phone['name']}".downcase.include?(chosen_phone.downcase) || chosen_phone.downcase.include?(phone['name'].downcase)
        end

        text = if filtered_phones.count > 0
          filtered_phones.map{|phone| "#{phone['make']} #{phone['name']} : *R#{phone['value'].to_f/100}*"}.join("\n")
        else
          "Unfortunately I could not find #{chosen_phone} :sob:"
        end

        client.say(channel: data.channel, text: text)
      end
    end
  end
end

