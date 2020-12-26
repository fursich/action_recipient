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
        match_with_any_whitelisted_addresses?(email) || match_with_any_whitelisted_domains?(domain_for(email))
      end

      def match_with_any_whitelisted_addresses?(email)
        whitelist.addresses.any? { |string_or_regexp|
          string_or_regexp === email
        }
      end

      def match_with_any_whitelisted_domains?(domain)
        whitelist.domains.any? { |string_or_regexp|
          string_or_regexp === domain
        }
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
