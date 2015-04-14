require "denouncer/version"

module Denouncer
  autoload :Notifiers, File.expand_path('../denouncer/notifiers', __FILE__)
  autoload :InfoError, File.expand_path('../denouncer/info_error', __FILE__)

  DEFAULT_NOTIFIER = :smtp

  @@notifiers = nil

  # Configures denouncer using the specified configuration hash.
  #
  # @param options [Hash] a configuration hash
  def self.configure(options)
    check_base_configuration! options
    if options[:notifier].nil? && options[:notifiers].nil?
      options[:notifier] = DEFAULT_NOTIFIER
    end

    unless options[:notifiers].nil?
      options[:notifiers] = options[:notifiers].map { |n| n.to_sym }
    end

    initialize_notifiers options
    options
  end

  def self.reset_configuration
    @@notifiers = nil
  end

  def self.is_configured?
    !notifiers.nil?
  end

  # Returns the current notifier's config or nil if not configured.
  def self.config
    return nil unless is_configured?
    if notifiers.count == 1
      notifiers.first.config
    else
      conf = {}
      conf[:application_name] = notifiers.first.config[:application_name]
      conf[:notifiers] = Array.new
      conf[:configurations] = {}
      notifiers.each do |notif|
        conf[:notifiers] << notif.name.to_sym
        conf[:configurations][notif.name.to_sym] = notif.config
      end
      conf
    end
  end

  # Sends a notification using the configured notifiers.
  #
  # @param error [StandardError]
  # @param metadata [Hash]
  def self.notify(error, metadata = nil)
    if is_configured?
      # ATTENTION: this ensures that no exceptions are lost when denouncer is not working as expected!!!
      # This is worth the downside of denouncer debugging thougths.
      begin
        notifiers.each do |notif|
          notif.notify error, metadata
        end
        return true
      rescue => err
        puts "An error occured while sending an exception notification via denouncer! Error: #{err.message}, Backtrace: #{err.backtrace}"
      end
    else
      return false
    end
  end

  # Sends a info notification using the configured notifiers.
  #
  # @param error [StandardError]
  # @param metadata [Hash]
  def self.info(info_message, metadata = nil)
    if is_configured?
      begin
        notifiers.each do |notif|
          notif.info info_message, metadata
        end
        return true
      rescue => err
        puts "An error occured while sending an info notification via denouncer! Error: #{err.message}, Backtrace: #{err.backtrace}"
      end
    else
      return false
    end
  end

  # Sends a notification and raises the given error on return
  #
  # @param error [StandardError]
  # @param metadata [Hash]
  # @raise [StandardError] the given error
  def self.notify!(error, metadata = nil)
    if is_configured?
      notifiers.each do |notif|
        notif.notify error, metadata
      end
    end
  rescue => err
    puts "An error occured while sending an exception notification via denouncer! Error: #{err.message}, Backtrace: #{err.backtrace}"
  ensure
    raise error
  end

  private

  def self.notifiers
    return @@notifiers
  end

  def self.check_base_configuration!(options)
    raise "Invalid configuration hash: nil" if options.nil?
    raise "Invalid configuration hash: No hash or subclass of hash given" unless options.is_a? Hash
    raise "Invalid configuration hash: No :application_name setting given" if options[:application_name].nil?

    if !options[:notifier].nil? && !options[:notifiers].nil?
      raise "Invalid configuration hash: Can't use :notifiers and :notifier setting in conjunction"
    end
  end

  def self.initialize_notifiers(options)
    @@notifiers = Array.new
    unless options[:notifiers].nil?
      intialize_multiple_notifiers options
    else
      initialize_single_notifier options[:notifier], options
    end
  rescue => err
    @@notifiers = nil
    raise err
  end

  def self.intialize_multiple_notifiers(options)
    raise "No :configurations hash given" if options[:configurations].nil?
    options[:notifiers].each do |notif_symbol|
      notif_symbol = notif_symbol.to_sym
      notifier_class = get_notifier_class notif_symbol

      notifier_opts = {
        application_name: options[:application_name],
      }

      notifier_opts.merge!(options[:configurations][notif_symbol])
      @@notifiers << notifier_class.new(notifier_opts)
    end
  end

  def self.initialize_single_notifier(notifier_symbol, options)
    notifier_class = get_notifier_class notifier_symbol
    @@notifiers << notifier_class.new(options)
  end

  def self.get_notifier_class(notifier_symbol)
    class_name = "::Denouncer::Notifiers::#{notifier_symbol.to_s.capitalize}Notifier"
    Kernel.const_get(class_name)
  rescue => err
    raise "Invalid notifier configuration: #{notifier_symbol} is not a valid :notifier setting! Error: #{err.message} !"
  end
end
