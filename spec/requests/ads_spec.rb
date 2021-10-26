require './spec/spec_helper'

RSpec.describe 'Ads API', type: :request do
  describe 'GET /' do
    let(:user_id) { SecureRandom.uuid }

    before do
      create_list(:ad, 3, user_id: user_id)
    end

    it 'returns a collection of ads' do
      get '/'

      expect(last_response.status).to eq(200)
      expect(response_body['data'].size).to eq(3)
    end
  end

  describe 'POST /ads' do
    let(:user_id) { SecureRandom.uuid }
    let(:auth_token) { 'token' }
    let(:auth_service) { instance_double('Auth service') }
    let(:geocoder_service) { instance_double('Geocoder service') }
    let(:coords) { { 'lat' => '37.9', 'lon' => '29.6' } }

    before do
      allow(AuthService::Client).to receive(:fetch).and_return(auth_service)
      allow(auth_service).to receive(:auth).with(auth_token)
      allow(auth_service).to receive(:user_id).and_return(user_id)
      allow(GeocoderService::Client).to receive(:new).and_return(geocoder_service)
      allow(geocoder_service).to receive(:geocode_later)
    end

    context 'missing parameters' do
      it 'returns an error' do
        status, _headers, _body = json_request('/ads', 'POST', auth_token: auth_token)

        expect(status).to eq(422)
      end
    end

    context 'missing user_id' do
      let(:user_id) { nil }

      let(:ad_params) do
        {
          title: 'Ad title',
          description: 'Ad description',
          city: ''
        }
      end

      it 'returns forbidden' do
        status, _headers, _body = json_request('/ads', 'POST', params: { ad: ad_params }, auth_token: auth_token)

        expect(status).to eq(403)
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

      it 'returns an error' do
        status, _headers, body = json_request('/ads', 'POST', params: { ad: ad_params }, auth_token: auth_token)

        expect(status).to eq(422)
        expect(JSON(body.first)['errors']).to include(
          {
            'detail' => "can't be blank",
            'source' => {
              'pointer' => '/data/attributes/city'
            }
          }
        )
      end
    end

    context 'valid parameters' do
      let(:ad_params) do
        {
          title: 'Ad title',
          description: 'Ad description',
          city: 'City'
        }
      end

      let(:last_ad) { Ad.last }

      it 'creates a new ad' do
        expect { json_request('/ads', 'POST', params: { ad: ad_params }, auth_token: auth_token) }
          .to change { Ad.count }.from(0).to(1)
      end

      it 'returns an ad' do
        status, _headers, body = json_request('/ads', 'POST', params: { ad: ad_params }, auth_token: auth_token)

        expect(JSON(body.first)['data']).to a_hash_including(
          'id' => last_ad.id.to_s,
          'type' => 'ad'
        )

        expect(status).to eq(201)
      end
    end
  end
end
