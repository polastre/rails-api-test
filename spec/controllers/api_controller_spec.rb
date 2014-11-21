require "rails_helper"
require "json"

RSpec.describe Api::ApiController, :type => :controller do
  describe "GET #distance" do
    it "is missing a parameter" do
      get :distance, { :first_name => "Alain", :ip_address => "50.0.193.21" }
      expect(response).to have_http_status(400)
    end

    it "responds successfully with nil" do
      get :distance, { :first_name => "alain", :last_name => "meier", :ip_address => "50.0.193.21" }
      expect(response).to be_success
      expect(response).to have_http_status(200)
      data = JSON.parse response.body
      expect(data['first_name']).to eq 'Alain'
      expect(data['last_name']).to eq 'Meier'
      expect(data['stated_distance_from_phone']).to be_within(0.1).of 1556.7
    end
  end

  describe "protected methods" do
    @controller = Api::ApiController.new
    let(:test_data) { JSON.parse '[
        {
          "first_name": "Alain",
          "last_name": "Meier",
          "phone_location": {
            "latitude": 51.5033630,
            "longitude": -0.1276250,
            "elevation": 19.36
          },
          "stated_location": {
            "latitude": 65.5033630,
            "longitude": -0.1276250,
            "elevation": 19.36
          }
        },
        {
          "first_name": "Alfred",
          "last_name": "Hitchcock",
          "phone_location": {
            "latitude": 51.5033630,
            "longitude": -0.1276250,
            "elevation": 2.19
          },
          "stated_location": {
            "latitude": 62.5033630,
            "longitude": -1.1276250,
            "elevation": 30.60
          }
        },
        {
          "first_name": "John",
          "last_name": "Doe",
          "phone_location": {
            "latitude": 51.5033630,
            "longitude": -0.1276250,
            "elevation": 19.36
          },
          "stated_location": {
            "latitude": 65.5033630,
            "longitude": -0.1276250,
            "elevation": 19.36
          }
        },
        {
          "first_name": "John",
          "last_name": "Doe",
          "phone_location": {
            "latitude": 51.5033630,
            "longitude": -0.1276250,
            "elevation": 2.19
          },
          "stated_location": {
            "latitude": 62.5033630,
            "longitude": -1.1276250,
            "elevation": 30.60
          }
        }
      ]' }

    it "calculates the distance between San Francisco and New York" do
      d = @controller.send :calc_distance, [37.7799084, -122.4143136], [40.7505781, -73.9685495]
      expect(d.ceil).to eq 4131
    end

    it "converts degrees to radians" do
      rad = @controller.send :to_rad, 148.35
      expect(rad).to be_within(0.0001).of 148.35 * Math::PI / 180
    end

    it "finds no matches" do
      d = @controller.send :find_matches, test_data, 'Winston', 'Churchill'
      expect(d.length).to eq 0
    end
    it "finds one match" do
      d = @controller.send :find_matches, test_data, 'alfred ', 'hItchcock'
      expect(d.length).to eq 1
      expect(d[0]['first_name']).to eq 'Alfred'
    end
    it "finds multiple matches" do
      d = @controller.send :find_matches, test_data, 'john ', 'doe'
      expect(d.length).to eq 2
      d.each do |di|
        expect(di['first_name']).to eq 'John'
      end
    end

  end
end
