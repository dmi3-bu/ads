class Application < Sinatra::Base
  helpers Sinatra::UrlForHelper
  include ::PaginationLinks
  include ::ApiErrors

  configure :development do
    register Sinatra::Reloader
    also_reload './app/**/*.rb'
  end

  get '/' do
    content_type :json
    ads = ::Ad.order(updated_at: :desc).page(params[:page])
    serializer = AdSerializer.new(ads, links: pagination_links(ads))

    serializer.serialized_json
  end

  post '/ads' do
    content_type :json
    current_user = SecureRandom.uuid
    params = JSON.parse(request.body.read).deep_symbolize_keys
    result = Ads::CreateService.call(
      ad: params[:ad],
      user_id: current_user
    )

    if result.success?
      serializer = AdSerializer.new(result.ad)
      status 201
      serializer.serialized_json
    else
      error_response(result.ad, :unprocessable_entity)
    end
  end
end