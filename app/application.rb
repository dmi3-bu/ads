class Application < Sinatra::Base
  helpers Sinatra::UrlForHelper
  include ::PaginationLinks
  include ::ApiErrors

  configure :development do
    register Sinatra::Reloader
    also_reload './app/**/*.rb'
    set :show_exceptions, false
  end

  get '/' do
    ads = ::Ad.order(updated_at: :desc).page(params[:page])
    serializer = AdSerializer.new(ads, links: pagination_links(ads))

    json serializer.serializable_hash
  end

  post '/ads' do
    current_user = SecureRandom.uuid
    params = JSON.parse(request.body.read).deep_symbolize_keys
    result = Ads::CreateService.call(
      ad: params[:ad],
      user_id: current_user
    )

    if result.success?
      serializer = AdSerializer.new(result.ad)
      status 201
      json serializer.serializable_hash
    else
      error_response(result.ad, :unprocessable_entity)
    end
  end

  error ActiveRecord::RecordNotFound do
    error_response(I18n.t(:not_found, scope: 'api.errors'), :not_found)
  end

  error ActiveRecord::RecordNotUnique do
    error_response(I18n.t(:not_unique, scope: 'api.errors'), :unprocessable_entity)
  end

  error KeyError, JSON::ParserError do
    error_response(I18n.t(:missing_parameters, scope: 'api.errors'), :unprocessable_entity)
  end
end
