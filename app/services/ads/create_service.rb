module Ads
  class CreateService
    prepend ::BasicService

    option :ad do
      option :title
      option :description
      option :city
    end

    option :user_id

    attr_reader :ad

    def call
      data = @ad.to_h.merge(user_id: @user_id)
      @ad = ::Ad.new(data)
      return fail!(@ad.errors) unless @ad.save

      if (other_ad = ::Ad.where(city: @ad.city).where.not(lat: nil, lon: nil).take)
        return @ad.update!(lat: other_ad.lat, lon: other_ad.lon)
      end

      coords = GeocoderService::Client.new.geocode(@ad.city)
      return if coords.blank?

      @ad.update!(lat: coords['lat'], lon: coords['lon'])
    end
  end
end
