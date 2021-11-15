Application.configure do |app|
  log_dev = app.production? ? STDOUT : "./log/#{Application.environment}.log"
  logger = Ougai::Logger.new(log_dev, level: 'debug')

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
