require 'root'
require 'root/insurance'
require 'slack-insure-bot/commands'

module SlackInsureBot
  class Bot < SlackRubyBot::Bot
    help do
      title 'Insurance Bot'
      desc 'This bot helps you with insurance enquiries.'

      command 'list all phone brands' do
        desc 'Gets a list of all the phone brands.'
      end

      command 'list all the phones made by <brand>' do
        desc 'Gets a list of all phones made by <brand>.'
      end

      command 'what is the value of a <phone>' do
        desc 'Gets the value of a specific phone <phone>.'
      end
    end
  end
end

