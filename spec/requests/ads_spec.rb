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

    context 'missing parameters' do
      it 'returns an error' do
        post '/ads'

        expect(last_response.status).to eq(422)
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
        status, _headers, body = json_request('/ads', 'POST', params: { ad: ad_params, user_id: user_id })

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
        expect { json_request('/ads', 'POST', params: { ad: ad_params, user_id: user_id }) }
          .to change { Ad.count }.from(0).to(1)
      end

      it 'returns an ad' do
        status, _headers, body = json_request('/ads', 'POST', params: { ad: ad_params, user_id: user_id })

        expect(JSON(body.first)['data']).to a_hash_including(
          'id' => last_ad.id.to_s,
          'type' => 'ad'
        )

        expect(status).to eq(201)
      end
    end
  end
end
