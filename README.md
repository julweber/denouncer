# Exceptionist

Exceptionist allows you to send notifications for occuring errors within your ruby applications.
Right now it supports SMTP to send mail notifications with error details.
The gem is designed to be extendable and provides a simple interface to implement other notification
methods.

## Installation

Add this line to your application's Gemfile:

    gem 'exceptionist'


And then execute:

    $ bundle

Or install it yourself as:

    $ gem install exceptionist

## Configuration

The configuration options depend on the chosen Notifier.
Basic configuration variables are:
* application_name - the name of your application (required)

### Console Notifier

The ConsoleNotifier is just for testing and demo purposes. It prints out exception details on the command line.

### SmtpNotifier

The STMP notifier sends email messages using the SMTP protocol.
Set the notifier configuration setting to :smtp to use the SmtpNotifier.

Configuration variables are:
* application_name - the name of your application (required)
* server - the smtp server address to use (default: localhost)
* port - the port to use for smtp connections (default: 25)
* domain - the from domain to use (default: localhost)
* username - the username for the smtp connection (default: nil)
* password - the password for the smtp connection (default: nil)
* authtype - the smtp auth type to use (default: :cram_md5) (:plain, :login or :cram_md5)
* sender - the sender (from) address to use (required)
* recipients - an array of recipients for the notifications (required)

#### External SMTP server

Exceptionist uses the Net::SMTP class to send mail. Additional configuration options are described [here](http://ruby-doc.org/stdlib-2.0/libdoc/net/smtp/rdoc/Net/SMTP.html).
    require 'exceptionist'

    Exceptionist.configure(
      application_name: 'my_app',
      notifier: :smtp,
      port: 25,
      server: 'mail.example.com',
      sender: 'noreply@example.com',
      username: 'noreply@example.com',
      password: 'your_password',
      recipients: ['usera@example.com', 'userb@example.com'],
      authtype: :plain,
      domain: 'mail.example.com'
    )

#### mailcatcher configuration

For more information in mailcatcher please refer to their [github repo](https://github.com/sj26/mailcatcher).

    require 'exceptionist'

    Exceptionist.configure(
      application_name: "my_app",
      notifier: :smtp,
      port: 1025,
      server: "localhost",
      sender: "noreply@example.com",
      recipients: ['usera@example.com', 'userb@example.com']
    )

## Usage

The example below shows a basic usage pattern for exceptionist notifications.
Catch exceptions, then use exceptionist's notify function and the re-raise the error again.

    begin
      1/0
    rescue => err
      Exceptionist.notify err
      raise err
    end

## Contributing

1. Fork it ( https://github.com/[my-github-username]/exceptionist/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
