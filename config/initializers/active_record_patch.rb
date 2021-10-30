module ActiveRecord
  class LogSubscriber
    def debug(progname = nil, &_block)
      Application.logger.debug('sql', query: progname)
    end
  end
end

module ActiveSupport
  class LogSubscriber
    def color(text, _color, _bold)
      text
    end
  end
end
