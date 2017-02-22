Rails.application.routes.draw do
  scope '/api', defaults: {format: :json} do
    namespace :v1 do
      post 'emails', to: 'emails#send_email'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
