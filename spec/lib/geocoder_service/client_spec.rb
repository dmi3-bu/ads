require './spec/spec_helper'

RSpec.describe GeocoderService::Client, type: :client do
  subject { described_class.new(connection: connection) }

  let(:status) { 200 }
  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:body) { { 'city' => city } }

  before do
    stubs.post('geocode') { [status, headers, body.to_json] }
  end

  describe '#geocode (valid city)' do
    let(:city) { 'Адыгейск' }
    let(:coords) { { 'lat' => '37.9', 'lon' => '29.6' } }
    let(:body) { { 'coords' => coords } }

    it 'returns user_id' do
      expect(subject.geocode(city)).to eq(coords)
    end
  end

  describe '#geocode (invalid city)' do
    let(:city) { 'Springfield' }
    let(:body) { { 'errors' => { 'details' => 'City not found' } } }

    it 'returns a nil value' do
      expect(subject.geocode(city)).to be_nil
    end
  end

  describe '#auth (nil city)' do
    let(:city) { '' }
    let(:body) { { 'errors' => { 'details' => 'Parameter missing' } } }

    it 'returns a nil value' do
      expect(subject.geocode(city)).to be_nil
    end
  end
end
