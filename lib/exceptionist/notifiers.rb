module Exceptionist
  module Notifiers
    autoload :BaseNotifier, File.expand_path('../notifiers/base_notifier', __FILE__)
    autoload :SmtpNotifier, File.expand_path('../notifiers/smtp_notifier', __FILE__)
  end
end
