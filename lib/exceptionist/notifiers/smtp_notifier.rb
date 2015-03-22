require 'net/smtp'
require 'time'

module Exceptionist
  module Notifiers
    class SmtpNotifier < BaseNotifier
      DEFAULT_PORT = 25
      DEFAULT_SERVER = 'localhost'

      def set_configuration!(options)
        raise "SMTP configuration error: #{options[:sender]} is not a valid :sender setting!" if options[:sender].nil? || !options[:sender].is_a?(String)
        raise "SMTP configuration error: :recipients is nil!" if options[:recipients].nil?

        options[:server] = DEFAULT_SERVER if options[:server].nil?
        options[:port] = DEFAULT_PORT if options[:port].nil?
      end

      # Sends an error notification via mail.
      #
      # @param [StandardError]
      def notify(error)
        # http://ruby-doc.org/stdlib-2.0/libdoc/net/smtp/rdoc/Net/SMTP.html
        Net::SMTP.start(config[:server], config[:port], 'localhost', config[:username], config[:password], config[:authtype]) do |smtp|
          smtp.send_message generate_html_message(error), config[:sender], config[:recipients]
        end
      end

      private

      def generate_html_message(error)
        time_now = Time.now.utc.iso8601
        msgstr = <<END_OF_MESSAGE
Subject: [ERROR] - #{config[:application_name]} - An exception occured
Date: #{time_now}

Application name:
#{config[:application_name]}

Notification time:
#{time_now} UTC

The error message was:
#{error.message}

The backtrace was:
#{error.backtrace}

The cause was:
#{error.cause}
END_OF_MESSAGE
        return msgstr
      end
    end
  end
end
