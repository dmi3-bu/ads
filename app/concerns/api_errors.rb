module ApiErrors
  extend ActiveSupport::Concern

  private

  def error_response(error_messages, status)
    errors = case error_messages
    when ActiveRecord::Base
      ErrorSerializer.from_model(error_messages)
    else
      ErrorSerializer.from_messages(error_messages)
    end

    status status
    json errors
  end
end
