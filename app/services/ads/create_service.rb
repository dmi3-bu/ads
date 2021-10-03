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

      # GeocodingJob.perform_later(@ad)
    end
  end
end
