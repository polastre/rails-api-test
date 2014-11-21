Rails.application.routes.draw do

  namespace :api, defaults: {format: :json} do
    match 'distance' => 'api#distance', via: [:get, :post]
  end

end
