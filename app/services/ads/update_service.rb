module Ads
  class UpdateService
    prepend BasicService

    param :id
    param :data
    option :ad, default: proc { Ad.where(id: @id).take }

    def call
      return fail!('Ad not found') if @ad.blank?

      @ad.update(lat: @data[:lat], lon: @data[:lon])
    end
  end
end