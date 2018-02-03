require 'root'
require 'root/insurance'

class AlexaService

  DEFAULT_CARD_IMAGE_SMALL = "https://s3-us-west-2.amazonaws.com/echo-demo-app-images/banana_small.png"
  DEFAULT_CARD_IMAGE_LARGE = "https://s3-us-west-2.amazonaws.com/echo-demo-app-images/banana_large.png"

  def initialize(params)
    @params = params
  end

  # Reponse contructed when the skill is launched
  def launch_request_response
    text = "Welcome, I'm your personal insurance helper. I can inform you of all the available phone brands, and all the available phone models of each brand. Do you need some help?"

    contruct_response(text)
  end

  # Determine the response for a given intent type
  def intent_response
    intent = @params['request']['intent']['name']

    if intent == "GetBrandsList"
      list_of_brands
    elsif intent == "GetPhonesList"
      list_of_phones

    elsif intent == "AMAZON.NoIntent" || intent == "AMAZON.YesIntent"
      # get yes of no answer
      answer = intent == "AMAZON.YesIntent"

      get_answer_response(answer)
    else
      unsure_response
    end
  end

  def list_of_brands
    root_client = Root::Insurance::Client.new(Settings.root.app_id, Settings.root.app_secret)

    makes = root_client.list_gadget_models.map{|phone| phone['make']}.uniq

    text = "The following phone brands are available. #{makes.to_sentence}."

    contruct_response(text)
  end

  def list_of_phones
    brand = @params['request']['intent']['slots']['Brand']['value']

    root_client = Root::Insurance::Client.new(Settings.root.app_id, Settings.root.app_secret)
    phones = root_client.list_gadget_models
    makes = phones.map{|phone| phone['make'].downcase}.uniq

    text = if makes.include?(brand.downcase)
      phones_for_brand = phones.select {|phone| phone['make'].downcase == brand.downcase}.map{|phone| phone['name']}

      count = phones_for_brand.count
      list = if count > 6
        "#{phones_for_brand[0..4].join(",")}, and about #{count - 5} more. You can get the full list by asking me in Slack."
      else
        phones_for_brand.to_sentence
      end

      list = list.tr('"', '').tr('(', '').tr(')', '')

      "The following #{brand} models are available. #{list}."
    else
      "#{brand} is not one of the options. The options are #{makes.to_sentence}."
    end

    contruct_response(text)
  end

  # Generic response if not sure about intent
  def unsure_response
    text = "I'm not exactly sure what you want. Bananas?"

    contruct_response(text)
  end

  def get_answer_response(answer)
    action_info = if answer
      "Ok fantastic. What do you want to know?"
    else
      "No problem, no problem at all. Unfortunately that is all I can do at the moment. Enjoy the rest of your day."
    end

    contruct_response(action_info)
  end

  # Construct response returned to Skill Interface
  def contruct_response(text, reprompt_text="", session_attributes=nil, session_end=false, card_image_small=DEFAULT_CARD_IMAGE_SMALL, card_image_large=DEFAULT_CARD_IMAGE_LARGE)
    if text.present?
      {"response": {
          "outputSpeech": {
            "type": "PlainText",
            "text": text
          },
          'card': {
            "type": 'Standard',
            "title": 'My Insurance Helper',
            "text": text,
            "image": {
              "smallImageUrl": card_image_small,
              "largeImageUrl": card_image_large
            }
          },
          "reprompt": {
            "outputSpeech": {
              "type": "PlainText",
              "text": reprompt_text
            }
          },
          "shouldEndSession": false
        },
        "sessionAttributes": session_attributes
      }
    else
      # Blank response
      {"response": {
          "outputSpeech": {
            "type": "PlainText",
            "text": ""
          },
          "shouldEndSession": false
        }
      }
    end
  end

end
