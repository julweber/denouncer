require 'net/smtp'
require 'time'
require 'socket'

module Denouncer
  module Notifiers
    class SmtpNotifier < BaseNotifier
      DEFAULT_PORT = 25
      DEFAULT_SERVER = 'localhost'
      DEFAULT_DOMAIN = 'localhost'

      # @raise [StandardError] if the configuration is invalid
      def set_configuration!(options)
        raise "Configuration error: :application_name is not set!" if options[:application_name].nil?
        raise "SMTP configuration error: #{options[:sender]} is not a valid :sender setting!" if options[:sender].nil? || !options[:sender].is_a?(String)
        raise "SMTP configuration error: :recipients is nil!" if options[:recipients].nil?

        options[:server] = DEFAULT_SERVER if options[:server].nil?
        options[:port] = DEFAULT_PORT if options[:port].nil?
        options[:domain] = DEFAULT_DOMAIN if options[:domain].nil?
        return options
      end

      # Sends an error notification via mail.
      #
      # @param error [StandardError]
      # @param metadata [Hash]
      def notify(error, metadata = nil)
        Net::SMTP.start(config[:server], config[:port], config[:domain], config[:username], config[:password], config[:authtype]) do |smtp|
          smtp.send_message generate_text_message(error), config[:sender], config[:recipients]
        end
      end

      private

      def generate_text_message(error, metadata = nil)
        hostname = Socket.gethostname
        time_now = get_current_timestamp
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

Additional metadata:
#{metadata.to_s}
END_OF_MESSAGE
        return msgstr
      end
    end
  end
end
