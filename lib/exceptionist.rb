require "exceptionist/version"

module Exceptionist
  autoload :Notifiers, File.expand_path('../exceptionist/notifiers', __FILE__)

  DEFAULT_NOTIFIER = :smtp

  @@notifier = nil

  # Configures exceptionist using the specified configuration hash.
  #
  # @param options [Hash] a configuration hash
  def self.configure(options)
    check_base_configuration! options
    if options[:notifier].nil?
      options[:notifier] = DEFAULT_NOTIFIER
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
    raise "Exceptionist is not configured yet. Please run Exceptionist.configure(options) to setup exceptionist!" if @@notifier.nil?
    notifier.notify error
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
    when :smtp then @@notifier = ::Exceptionist::Notifiers::SmtpNotifier.new options
    when :console then @@notifier = ::Exceptionist::Notifiers::ConsoleNotifier.new options
    else
      raise "Invalid notifier configuration: #{options} is not a valid :notifier setting!"
    end
  end
end
