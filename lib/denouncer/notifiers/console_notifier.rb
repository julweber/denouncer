module Denouncer
  module Notifiers
    class ConsoleNotifier < BaseNotifier
      
      # @return [String]
      def name
        'console'
      end

      def set_configuration!(options)
        return options
      end

      def notify(error, metadata = nil)
        puts "Timestamp: #{get_current_timestamp.to_s}"
        puts "Error Class: #{error.class.name}"
        puts "Error Message: #{error.message}"
        puts "Metadata: #{metadata.to_s}"
      end
    end
  end
end
