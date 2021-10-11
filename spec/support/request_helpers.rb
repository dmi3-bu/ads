module RequestHelpers
  def response_body
    JSON(last_response.body)
  end

  def json_request(uri, method, params: {}, auth_token: nil)
    request = Rack::MockRequest.env_for(uri, method: method, params: params.to_json)
    request['CONTENT_TYPE'] = 'application/json'
    request['HTTP_AUTHORIZATION'] = "Bearer #{auth_token}" if auth_token
    Application.call(request)
  end
end
