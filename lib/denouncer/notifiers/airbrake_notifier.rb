require 'socket'
require 'json'

module Denouncer
  module Notifiers
    class AirbrakeNotifier < BaseNotifier

      # @return [String]
      def name
        'airbrake'
      end

      def set_configuration!(options)
        raise "Airbrake configuration error: :api_key is nil!" if options[:api_key].nil?
        require 'airbrake'
        Airbrake.configure do |config|
          config.api_key = options[:api_key]
        end
        return options
      end

      # Sends an error notification via amqp.
      #
      # @param error [StandardError]
      # @param metadata [Hash]
      def notify(error, metadata = nil)
        Airbrake.notify(error,
          api_key: config[:api_key],
          error_message: error.message,
          backtrace: error.backtrace
        )
      end
    end
  end
end
