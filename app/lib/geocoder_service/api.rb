module GeocoderService
  module Api
    def geocode(city)
      response = connection.post('geocode') do |request|
        request.body = { city: city }.to_json
      end
      response.body['coords'] if response.success?
    end
  end
end
