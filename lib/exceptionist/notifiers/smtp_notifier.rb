require 'net/smtp'
require 'time'
require 'socket'

module Exceptionist
  module Notifiers
    class SmtpNotifier < BaseNotifier
      DEFAULT_PORT = 25
      DEFAULT_SERVER = 'localhost'
      DEFAULT_DOMAIN = 'localhost'

      def set_configuration!(options)
        raise "SMTP configuration error: #{options[:sender]} is not a valid :sender setting!" if options[:sender].nil? || !options[:sender].is_a?(String)
        raise "SMTP configuration error: :recipients is nil!" if options[:recipients].nil?

        options[:server] = DEFAULT_SERVER if options[:server].nil?
        options[:port] = DEFAULT_PORT if options[:port].nil?
        options[:domain] = DEFAULT_DOMAIN if options[:domain].nil?
      end

      # Sends an error notification via mail.
      #
      # @param [StandardError]
      def notify(error)
        # http://ruby-doc.org/stdlib-2.0/libdoc/net/smtp/rdoc/Net/SMTP.html
        Net::SMTP.start(config[:server], config[:port], config[:domain], config[:username], config[:password], config[:authtype]) do |smtp|
          smtp.send_message generate_html_message(error), config[:sender], config[:recipients]
        end
      end

      private

      def generate_html_message(error)
        hostname = Socket.gethostname
        time_now = Time.now.utc.iso8601
        msgstr = <<END_OF_MESSAGE
From: #{config[:application_name]} <#{config[:sender]}>
Subject: [ERROR] - #{config[:application_name]} - An exception occured
Date: #{time_now}

Application name:
#{config[:application_name]}

Hostname:
#{hostname}

Notification time:
#{time_now} UTC

Error class:
#{error.class.name}

Error message:
#{error.message}

Backtrace:
#{error.backtrace}

Error cause:
#{error.cause}
END_OF_MESSAGE
        return msgstr
      end
    end
  end
end
