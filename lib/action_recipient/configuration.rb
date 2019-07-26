module ActionRecipient
  class << self
    def configure &block
      block.call config
    end

    def config
      @config ||= Configuration.new
    end

    def reset_config!
      @config = nil
    end
  end

  class Configuration
    attr_writer :whitelist, :format

    def whitelist
      @whitelist ||= []
    end

    def format
      @format ||= '%s'
    end
  end
end
