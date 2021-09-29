module RequestHelpers
  def response_body
    JSON(last_response.body)
  end
end
