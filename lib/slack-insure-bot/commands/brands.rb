require 'root'
require 'root/insurance'

module SlackInsureBot
  module Commands
    class Brands < SlackRubyBot::Commands::Base
      command 'list all phone brands' do |client, data, _match|
        root_client = Root::Insurance::Client.new(Settings.root.app_id, Settings.root.app_secret)

        makes = root_client.list_gadget_models.map{|phone| phone['make']}.uniq

        client.say(channel: data.channel, text: makes.join("\n"))
      end
    end
  end
end

