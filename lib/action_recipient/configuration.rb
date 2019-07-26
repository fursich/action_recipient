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
    attr_writer :format

    def whitelist
      @whitelist ||= Whitelist.new
    end

    def format
      @format ||= '%s'
    end

    class Whitelist
      attr_writer :domains, :addresses

      def [](key)
        public_send(key) if %i[domains addresses].include? key
      end

      def domains
        @domains ||= []
      end

      def addresses
        @addresses ||= []
      end
    end
  end
end
