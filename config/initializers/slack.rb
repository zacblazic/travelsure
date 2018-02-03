ENV['SLACK_API_TOKEN'] = Settings.slack.api_token

SlackRubyBot::Client.logger.level = Logger::WARN
