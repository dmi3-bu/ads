module RabbitMq
  extend self

  @mutex = Mutex.new

  def connection
    @mutex.synchronize do
      @connection ||= Bunny.new(
        host: Settings.rabbitmq.host,
        username: Settings.rabbitmq.username,
        password: Settings.rabbitmq.password
      ).start
    end
  end

  def channel
    Thread.current[:rabbitmq_channel] ||= connection.create_channel
  end
end