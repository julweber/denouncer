require "denouncer/version"

module Denouncer
  autoload :Notifiers, File.expand_path('../denouncer/notifiers', __FILE__)

  DEFAULT_NOTIFIER = :smtp

  @@notifier = nil

  # Configures denouncer using the specified configuration hash.
  #
  # @param options [Hash] a configuration hash
  def self.configure(options)
    check_base_configuration! options
    if options[:notifier].nil?
      options[:notifier] = DEFAULT_NOTIFIER
    else
      options[:notifier] = options[:notifier].to_sym
    end
    initialize_notifier options
    options
  end

  def self.reset_configuration
    @@notifier = nil
  end

  def self.is_configured?
    !notifier.nil?
  end

  # Returns the current notifier's config or nil if not configured.
  def self.config
    return nil unless is_configured?
    notifier.config
  end

  # Sends a notification using the configured notifier.
  #
  # @param error [StandardError]
  # @param metadata [Hash]
  def self.notify(error, metadata = nil)
    if is_configured?
      # ATTENTION: this ensures that no exceptions are lost when denouncer is not working as expected!!!
      # This is worth the downside of denouncer debugging thougths.
      begin
        notifier.notify error, metadata
        return true
      rescue => err
        puts "An error occured while sending an exception notification via denouncer!"
        raise error
      end
    else
      return false
    end
  end

  private

  def self.notifier
    return @@notifier
  end

  def self.check_base_configuration!(options)
    raise "Invalid configuration hash: nil" if options.nil?
    raise "Invalid configuration hash: no hash or subclass of hash given" unless options.is_a? Hash
  end

  def self.initialize_notifier(options)
    case options[:notifier]
    when :smtp then @@notifier = ::Denouncer::Notifiers::SmtpNotifier.new options
    when :console then @@notifier = ::Denouncer::Notifiers::ConsoleNotifier.new options
    when :amqp then @@notifier = ::Denouncer::Notifiers::AmqpNotifier.new options
    else
      raise "Invalid notifier configuration: #{options} is not a valid :notifier setting!"
    end
  end
end