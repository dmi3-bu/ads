Application.configure do |app|
  logger = Ougai::Logger.new("./log/#{Application.environment}.log", level: 'debug')

  if Application.development?
    logger.formatter = Ougai::Formatters::Readable.new
  end

  logger.before_log = lambda do |data|
    data[:service] = { name: 'ads' }
    data[:request_id] ||= Thread.current[:request_id]
  end

  app.set :logger, logger
end

ActiveRecord::Base.logger = Application.logger
