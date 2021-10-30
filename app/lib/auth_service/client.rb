require 'dry/initializer'

module AuthService
  class Client
    extend Dry::Initializer[undefined: false]
    include AuthService::Api

    option :queue,       default: proc { create_queue }
    option :reply_queue, default: proc { create_reply_queue }
    option :lock,        default: proc { Mutex.new }
    option :condition,   default: proc { ConditionVariable.new }

    attr_reader :user_id

    def self.fetch
      Thread.current['auth_service.rpc_client'] ||= new.start
    end

    def start
      @reply_queue.subscribe do |_delivery_info, properties, payload|
        if properties[:correlation_id] == @correlation_id
          @user_id = JSON.parse(payload)['meta']['user_id'] rescue nil

          @lock.synchronize { @condition.signal }
        end
      end

      self
    end

    private

    def create_queue
      channel = RabbitMq.channel
      channel.queue('auth', durable: true)
    end

    def create_reply_queue
      channel = RabbitMq.channel
      channel.queue('amq.rabbitmq.reply-to')
    end

    def publish(payload, opts = {})
      @lock.synchronize do
        @correlation_id = SecureRandom.uuid

        @queue.publish(
          payload,
          opts.merge(
            app_id: 'ads',
            reply_to: @reply_queue.name,
            correlation_id: @correlation_id,
            headers: {
              request_id: Thread.current[:request_id]
            }
          )
        )

        @condition.wait(@lock)
      end
    end
  end
end
