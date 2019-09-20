require 'mail'

module Delivery
  class Email
    def initialize
      Mail.defaults do
        delivery_method :smtp, Config::Delivery::OPTIONS
      end
    end

    def deliver(message)
      puts 'Sending SMS message via email'
      Mail.deliver do
             to Config::Delivery::TO_ADDRESS
           from Config::Delivery::FROM_ADDRESS
           body message
      end
    end
  end
end
