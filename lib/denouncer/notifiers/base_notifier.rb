require 'time'

module Denouncer
  module Notifiers
    class BaseNotifier
      attr_reader :config

      def initialize(options)
        if options[:application_name].nil? || !options[:application_name].is_a?(String)
          raise "Invalid configuration hash: No valid :application_name given"
        end
        opts = set_configuration!(options).dup
        @config = opts
      end

      # Returns the current timestamp in utc is8601 format
      def get_current_timestamp
        Time.now.utc
      end

      # returns the given error's cause if available
      def get_error_cause(error)
        if error.respond_to? :cause
          error.cause
        else
          nil
        end
      end

      # @return [String] the name for the notifier
      def name
        raise NotImplementedException("This method needs to be implemented in a sub-class!")
      end

      def set_configuration!(options)
        raise NotImplementedException("This method needs to be implemented in a sub-class!")
      end

      # Sends an error notification.
      #
      # @param error [StandardError]
      # @param metadata [Hash]
      def notify(error, metadata = nil)
        raise NotImplementedException("This method needs to be implemented in a sub-class!")
      end

      # Sends a info notification.
      #
      # @param info_message [String]
      # @param metadata [Hash]
      def info(info_message, metadata = nil)
        raise NotImplementedException("This method needs to be implemented in a sub-class!")
      end
    end
  end
end
