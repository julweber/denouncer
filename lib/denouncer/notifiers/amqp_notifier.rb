require 'socket'
require 'json'

module Denouncer
  module Notifiers
    class AmqpNotifier < BaseNotifier
      DEFAULT_PORT = 5672
      DEFAULT_SERVER = 'localhost'
      DEFAULT_VHOST = '/'
      DEFAULT_USERNAME = 'guest'
      DEFAULT_PASSWORD = 'guest'

      # @return [String]
      def name
        'amqp'
      end

      def set_configuration!(options)
        raise "Configuration error: :application_name is not set!" if options[:application_name].nil?
        require 'bunny'

        options[:server] = DEFAULT_SERVER if options[:server].nil?
        options[:port] = DEFAULT_PORT if options[:port].nil?
        options[:vhost] = DEFAULT_VHOST if options[:vhost].nil?
        options[:username] = DEFAULT_USERNAME if options[:username].nil?
        options[:password] = DEFAULT_PASSWORD if options[:password].nil?
        options[:message_queue] = "#{options[:application_name]}.errors" if options[:message_queue].nil?
        return options
      end

      # Sends an error notification via amqp.
      #
      # @param error [StandardError]
      # @param metadata [Hash]
      def notify(error, metadata = nil)
        msg = generate_error_hash(error, metadata).to_json
        send_message_via_amqp msg
      end

      # Sends a info notification.
      #
      # @param info_message [String]
      # @param metadata [Hash]
      def info(info_message, metadata = nil)
        msg = generate_info_hash(info_message, metadata).to_json
        send_message_via_amqp msg
      end

      private

      def generate_error_hash(error, metadata = nil)
        hostname = Socket.gethostname
        time_now = get_current_timestamp
        {
          notification_time: time_now,
          application_name: config[:application_name],
          hostname: hostname,
          error_class: error.class.name,
          error_backtrace: error.backtrace,
          error_message: error.message,
          error_cause: get_error_cause(error),
          metadata: metadata
        }
      end

      def generate_info_hash(message, metadata = nil)
        hostname = Socket.gethostname
        time_now = get_current_timestamp
        {
          notification_time: time_now,
          application_name: config[:application_name],
          hostname: hostname,
          message: message,
          metadata: metadata
        }
      end

      def send_message_via_amqp(message)
        # Start a communication session with RabbitMQ
        connection_hash = {
          host: config[:server],
          vhost: config[:vhost],
          port: config[:port],
          username: config[:username],
          password: config[:password],
          threaded: false
        }
        conn = Bunny.new connection_hash
        conn.start

        # open a channel
        ch = conn.create_channel

        # declare a queue
        q  = ch.queue(config[:message_queue])

        # publish a message to the default exchange which then gets routed to this queue
        q.publish(message)

        # close the connection
        conn.stop
      end
    end
  end
end
