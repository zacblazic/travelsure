# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
require_relative 'lib/slack-insure-bot/bot'

Thread.abort_on_exception = true
Thread.new do
  SlackInsureBot::Bot.run if ENV['SLACK_API_TOKEN'] 
end

run Rails.application
