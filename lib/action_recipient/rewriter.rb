module ActionRecipient
  module Rewriter
    class << self
      def rewrite_addresses!(message, type, prefix: '')
        address_container = message[type]&.field&.addrs
        return unless address_container

        message[type] = address_container.map { |address_object|
          if whitelisted?(address_object.address)
            address_object.to_s
          else
            rewrite(address_object.address, prefix, format)
          end
        }
      end

      def rewrite(email, prefix, format)
        format % "#{prefix}#{email.gsub('@', '_at_').gsub(/[^\.\w]/, '-')}"
      end

      def whitelisted?(email)
        whitelist.addresses.include?(email) || whitelist.domains.include?(domain_for(email))
      end

      def whitelist
        ActionRecipient.config.whitelist
      end

      def format
        ActionRecipient.config.format
      end

      def domain_for(email)
        email.split('@').last
      end
    end
  end
end
