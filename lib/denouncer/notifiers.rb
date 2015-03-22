module Denouncer
  module Notifiers
    autoload :BaseNotifier, File.expand_path('../notifiers/base_notifier', __FILE__)
    autoload :ConsoleNotifier, File.expand_path('../notifiers/console_notifier', __FILE__)
    autoload :SmtpNotifier, File.expand_path('../notifiers/smtp_notifier', __FILE__)
    autoload :AmqpNotifier, File.expand_path('../notifiers/amqp_notifier', __FILE__)
  end
end