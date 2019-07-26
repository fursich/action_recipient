require_relative 'rewriter'

module ActionRecipient
  module Interceptor
    def self.delivering_email(message)
      ActionRecipient::Rewriter.rewrite_addresses!(message, :to)
      ActionRecipient::Rewriter.rewrite_addresses!(message, :cc,  prefix: 'cc_')
      ActionRecipient::Rewriter.rewrite_addresses!(message, :bcc, prefix: 'bcc_')
    end
  end
end
