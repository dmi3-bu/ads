require './spec/spec_helper'

RSpec.describe Ads::CreateService do
  subject { described_class }

  let(:user_id) { SecureRandom.uuid }
  let(:geocoder_service) { instance_double('Geocoder service') }
  let(:coords) { { 'lat' => '37.9', 'lon' => '29.6' } }

  before do
    allow(GeocoderService::Client).to receive(:new).and_return(geocoder_service)
    allow(geocoder_service).to receive(:geocode).and_return(coords)
  end

  context 'valid parameters' do
    let(:ad_params) do
      {
        title: 'Ad title',
        description: 'Ad description',
        city: 'City'
      }
    end

    it 'creates a new ad' do
      expect { subject.call(ad: ad_params, user_id: user_id) }
        .to change { Ad.count }.from(0).to(1)
    end

    it 'assigns ad' do
      result = subject.call(ad: ad_params, user_id: user_id)

      expect(result.ad).to be_kind_of(Ad)
    end

    it 'calls geocoder service and saves coords to ad' do
      expect(GeocoderService::Client).to receive(:new).and_return(geocoder_service)
      expect(geocoder_service).to receive(:geocode).and_return(coords)

      result = subject.call(ad: ad_params, user_id: user_id)
      expect(result.ad.lat).to eq(37.9)
      expect(result.ad.lon).to eq(29.6)
    end
  end

  context 'invalid parameters' do
    let(:ad_params) do
      {
        title: 'Ad title',
        description: 'Ad description',
        city: ''
      }
    end

    it 'does not create ad' do
      expect { subject.call(ad: ad_params, user_id: user_id) }
        .not_to change { Ad.count }
    end

    it 'assigns ad' do
      result = subject.call(ad: ad_params, user_id: user_id)

      expect(result.ad).to be_kind_of(Ad)
    end

    it 'does not call geocoder service' do
      expect(GeocoderService::Client).not_to receive(:new)

      subject.call(ad: ad_params, user_id: user_id)
    end
  end
end
