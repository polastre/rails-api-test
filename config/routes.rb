Rails.application.routes.draw do

  namespace :api, defaults: {format: :json} do
    get 'distance' => 'api#distance'
  end

end
