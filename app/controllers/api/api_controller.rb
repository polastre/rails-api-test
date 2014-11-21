require File.expand_path('../../validations/distance', __FILE__)
require 'json'

class Api::ApiController < ApplicationController

  before_action :validate_params

  ActionController::Parameters.action_on_unpermitted_parameters = :raise

  def distance
    # Put the parameters into a model to manage them
    dq = DistanceQuery.new(first_name: params[:first_name], last_name: params[:last_name], ip_address: params[:ip_address])
    # Geocode the ip address
    dq.geocode
    # If geocoding fails, provide an error message
    if !dq.geocoded?
      render json: { error: 'unable to geocode provided ip address' }, 
             status: :unprocessable_entity
      return
    end

    # Get the data from the remote provider
    begin
      resource = RestClient::Resource.new('http://private-5e0de-nodejsapitestprovider.apiary-mock.com/api/people', :timeout => 20)
      response = resource.get
    rescue => e
      render json: { error: 'request timed out contacting remote provider' },
             status: :internal_server_error
    end

    # Find matches for the results returned
    records = JSON.parse response.to_str
    matches = find_matches records, dq.first_name, dq.last_name

    # Calculate the distance for each match
    results = []
    ll = [dq.latitude, dq.longitude]
    matches.each do |m|
      m['phone_distance_from_ip'] = calc_distance(
        [m['phone_location']['latitude'], m['phone_location']['longitude']],
        ll
      )
      m['stated_distance_from_ip'] = calc_distance(
        [m['stated_location']['latitude'], m['stated_location']['longitude']],
        ll
      )
      m['stated_distance_from_phone'] = calc_distance(
        [m['phone_location']['latitude'], m['phone_location']['longitude']],
        [m['stated_location']['latitude'], m['stated_location']['longitude']]
      )
      results.push m
    end
    # If there's only one result, as per spec, don't put it in the array
    if results.length == 1
      results = results[0]
    end
    render :json => results and return
  end

  # Attribute validation -- kick out invalid attributes
  rescue_from(ActionController::UnpermittedParameters) do |pme|
    render json: { error: { unknown_parameters: pme.params } }, 
           status: :bad_request
  end

  protected

  # The radius of the earth!
  RADIUS = 6371

  # Calculate the distance between two points
  # The points should be specified as [lat, lon]
  # Returns the distance in kilomters
  def calc_distance(l1, l2)
    # Calculate the raw distances between points
    # And convert to radians; no one uses degress in math
    dist = [
      to_rad(l2[0] - l1[0]),
      to_rad(l2[1] - l1[1])
    ]
    # Use the haversine formula
    a = Math::sin(dist[0]/2) * Math::sin(dist[0]/2) +
      Math::cos(to_rad l1[0]) * Math::cos(to_rad l2[0]) *
      Math::sin(dist[1]/2) * Math::sin(dist[1]/2);
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
    d = RADIUS * c
    # Return the distance in kilometers
    return d
  end

  # Find all of the entries in data that match first_name and last_name
  # returned as an array
  def find_matches(data, first_name, last_name)
    fn = first_name.downcase.strip
    ln = last_name.downcase.strip
    result = []
    data.each do |d|
      if d['first_name'].downcase.strip == fn && d['last_name'].downcase.strip == ln
        result.push d
      end
    end
    return result
  end    

  private

  def to_rad(degrees)
    return degrees * Math::PI / 180
  end

  def validate_params
    d = Validate::Distance.new(params)
    if !d.valid?
      render :json => { error: d.errors }, status: :bad_request and return
    end
  end

end
