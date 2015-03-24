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
        options[:authtype] = options[:authtype].to_sym unless options[:authtype].nil?
        return options
      end

      # Sends an error notification via mail.
      #
      # @param error [StandardError]
      # @param metadata [Hash]
      def notify(error, metadata = nil)
        Net::SMTP.start(config[:server], config[:port], config[:domain], config[:username], config[:password], config[:authtype]) do |smtp|
          smtp.send_message generate_text_message(error, metadata), config[:sender], config[:recipients]
        end
      end

      private

      def generate_text_message(error, metadata = nil)
        hostname = Socket.gethostname
        time_now = get_current_timestamp
        recipients_list = formatted_recipients
        msgstr = <<END_OF_MESSAGE
From: #{config[:application_name]} <#{config[:sender]}>
To: #{recipients_list}
Subject: [ERROR] - #{config[:application_name]} - An exception occured
Date: #{formatted_time(time_now)}

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
#{formatted_backtrace(error)}

Error cause:
#{error.cause}

Metadata:
#{metadata.to_s}
END_OF_MESSAGE
        return msgstr
      end

      def formatted_recipients
        rec = ""
        config[:recipients].each_with_index do |r, i|
          if (i == config[:recipients].length - 1)
            rec << r
          else
            rec << r << ", "
          end
        end
        rec
      end

      def formatted_time(time)
        time.strftime("%a, %e %b %Y %H:%M:%S %z")
      end

      def formatted_backtrace(error)
        bt = error.backtrace
        return "No backtrace available!" if bt.nil?
        str = ""
        bt.each do |line|
          str << line << "\n"
        end
        return str
      end

    end
  end
end
