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

  # describe 'POST /ads (valid auth token)' do
  #   let(:user_id) { SecureRandom.uuid }
  #
  #   context 'missing parameters' do
  #     it 'returns an error' do
  #       request = Rack::MockRequest.env_for('/ads', method: 'POST', headers: auth_headers(user_id))
  #       request['CONTENT_TYPE'] = 'application/json'
  #       status, _headers, body = Application.call(request)
  #
  #       expect(status).to eq(422)
  #     end
  #   end
  #
  #   context 'invalid parameters' do
  #     let(:ad_params) do
  #       {
  #         title: 'Ad title',
  #         description: 'Ad description',
  #         city: ''
  #       }
  #     end
  #
  #     it 'returns an error' do
  #       post '/ads', headers: auth_headers(user_id), params: { ad: ad_params }
  #
  #       expect(response).to have_http_status(:unprocessable_entity)
  #       expect(response_body['errors']).to include(
  #         {
  #           'detail' => 'Укажите город',
  #           'source' => {
  #             'pointer' => '/data/attributes/city'
  #           }
  #         }
  #       )
  #     end
  #   end
  #
  #   context 'valid parameters' do
  #     let(:ad_params) do
  #       {
  #         title: 'Ad title',
  #         description: 'Ad description',
  #         city: 'City'
  #       }
  #     end
  #
  #     let(:last_ad) { Ad.last }
  #
  #     it 'creates a new ad' do
  #       expect { post '/ads', headers: auth_headers(user), params: { ad: ad_params } }
  #         .to change { Ad.count }.from(0).to(1)
  #
  #       expect(response).to have_http_status(:created)
  #     end
  #
  #     it 'returns an ad' do
  #       post '/ads', headers: auth_headers(user_id), params: { ad: ad_params }
  #
  #       expect(response_body['data']).to a_hash_including(
  #         'id' => last_ad.id.to_s,
  #         'type' => 'ad'
  #       )
  #     end
  #   end
  # end

  # describe 'POST /ads (invalid auth token)' do
  #   let(:ad_params) do
  #     {
  #       title: 'Ad title',
  #       description: 'Ad description',
  #       city: 'City'
  #     }
  #   end
  #
  #   it 'returns an error' do
  #     request = Rack::MockRequest.env_for('/ads', method: 'POST', params: { ad: ad_params }.to_json)
  #     request['CONTENT_TYPE'] = 'application/json'
  #     status, _headers, body = Application.call(request)
  #
  #     expect(status).to eq(:forbidden)
  #     expect(body['errors']).to include('detail' => 'Доступ к ресурсу ограничен')
  #   end
  # end
end
