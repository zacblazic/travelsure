Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  get 'account/index'

  root 'welcome#index'

  post "alexa" => "webhooks#alexa", as: :alexa

  namespace "facebook" do
    get  "webhook" => "webhooks#verify"
    post "webhook" => "webhooks#events"
  end

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
