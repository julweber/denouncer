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
Default configuration variables are:
* application_name - the name of your application

### SMTP Notifier

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
