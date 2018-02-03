class Facebook::WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:events]

  def verify
    mode = params['hub.mode']
    token = params['hub.verify_token']
    challenge = params['hub.challenge']

    if mode == 'subscribe' && token == verify_token
      render plain: challenge
    else
      render plain: nil, status: 403
    end
  end

  def events
    if params['object'] == 'page'
      params['entry'].each do |entry|
        webhook_event = entry['messaging'][0]
        sender_id = webhook_event['sender']['id']

        if webhook_event['message']
          FacebookService.handle_message(sender_id, webhook_event['message'])
        end
      end

      render plain: 'EVENT_RECEIVED', status: 200
    else
      render plain: nil, status: 404
    end
  end

  private
  def verify_token
    Settings.facebook.verify_token
  end

end
