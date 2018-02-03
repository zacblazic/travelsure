class WebhooksController < ApplicationController
  skip_before_action  :verify_authenticity_token

  def alexa
    request_type = params['request']['type']

    response = case request_type
    when "IntentRequest"
      AlexaService.new(params).intent_response
    when "LaunchRequest"
      AlexaService.new(params).launch_request_response
    else
      # Blank response for terminate session request
      AlexaService.new(params).contruct_response("")
    end

    render json: response
  end

end
