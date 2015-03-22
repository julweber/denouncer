module Exceptionist
  module Notifiers
    class BaseNotifier
      attr_reader :config

      def initialize(options)
        if options[:application_name].nil? || !options[:application_name].is_a?(String)
          raise "Invalid configuration hash: No valid :application_name given"
        end
        set_configuration! options
        @config = options.dup
      end

      def set_configuration!(options)
        raise NotImplementedException("This method needs to be implemented in a sub-class!")
      end

      def notify(error)
        raise NotImplementedException("This method needs to be implemented in a sub-class!")
      end
    end
  end
end
