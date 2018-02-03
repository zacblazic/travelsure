require 'root'
require 'root/insurance'

module SlackInsureBot
  module Commands
    class Phones < SlackRubyBot::Commands::Base
      command 'list all the phones made by' do |client, data, match|
        action = "list all the phones made by "

        make = if data.text.index(action)
          n = data.text.index(action)
          data.text[n..-1]
        else
          data.text
        end

        make.slice!(action)

        root_client = Root::Insurance::Client.new(Settings.root.app_id, Settings.root.app_secret)
        phones = root_client.list_gadget_models
        makes = phones.map{|phone| phone['make'].downcase}.uniq

        text = if makes.include?(make.downcase)
          phones.select {|phone| phone['make'].downcase == make.downcase}.map{|phone| phone['name']}.join("\n")
        else
          "#{make} is not one of the options. The options are #{makes.to_sentence}."
        end

        client.say(channel: data.channel, text: text)
      end
    end
  end
end

