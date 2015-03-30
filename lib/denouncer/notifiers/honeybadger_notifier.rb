require 'socket'
require 'json'

module Denouncer
  module Notifiers
    class HoneybadgerNotifier < BaseNotifier

      # @return [String]
      def name
        'honeybadger'
      end

      def set_configuration!(options)
        require 'honeybadger'
        require 'rack/request'
        Honeybadger.start
        return options
      end

      # Sends an error notification via amqp.
      #
      # @param error [StandardError]
      # @param metadata [Hash]
      def notify(error, metadata = nil)
        Honeybadger.notify(
          error_class: error.class.name,
          error_message: error.message,
          parameters: metadata
        )
      end
    end
  end
end
