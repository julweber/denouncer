# Denouncer

Denouncer allows you to send notifications for occuring errors within your ruby applications.
Right now it supports SMTP to send mail notifications with error details.
The gem is designed to be extendable and provides a simple interface to implement other notification
methods.

## Build status

[![Build Status](https://travis-ci.org/julweber/denouncer.svg)](https://travis-ci.org/julweber/denouncer)

## Current gem version

[![Gem Version](https://badge.fury.io/rb/denouncer.svg)](http://badge.fury.io/rb/denouncer)

## Installation

Add this line to your application's Gemfile:

    gem 'denouncer'


And then execute:

    $ bundle

Or install it yourself as:

    $ gem install denouncer

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

Denouncer uses the Net::SMTP class to send mail. Additional configuration options are described [here](http://ruby-doc.org/stdlib-2.0/libdoc/net/smtp/rdoc/Net/SMTP.html).
    require 'denouncer'

    Denouncer.configure(
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

    require 'denouncer'

    Denouncer.configure(
      application_name: "my_app",
      notifier: :smtp,
      port: 1025,
      server: "localhost",
      sender: "noreply@example.com",
      recipients: ['usera@example.com', 'userb@example.com']
    )

### AmqpNotifier

Denouncer uses the bunny gem to send mail. Additional configuration options are described [here](http://reference.rubybunny.info/).

#### !!!ATTENTION

The bunny gem is required for the AmqpNotifier. Please add the bunny gem to your Gemfile as follows:

    gem 'bunny'

Configuration variables are:
* application_name - the name of your application (required)
* server - the amqp server address to use (default: localhost)
* port - the port to use for amqp connections (default: 5672)
* username - the username for the amqp connection (default: 'guest')
* password - the password for the amqp connection (default: 'guest')
* vhost - the virtual host to use for the amqp connection (default: '/')
* message_queue - the message queue to use (default: "#{application_name}.errors", e.g. "myapp.errors")

#### AMQP Configuration

    require 'denouncer'

    Denouncer.configure(
      application_name: "my_app",
      notifier: :amqp,
      port: 5672,
      server: "localhost",
      vhost: "/",
      username: "guest",
      password: "guest",
      message_queue: "my_app.errors"
    )

#### HoneybadgerNotifier

For more information on honeybadger please refer to their [github repo](https://github.com/honeybadger-io/honeybadger-ruby).

#### !!!ATTENTION

The honeybadger and rack gems are required for the HoneybadgerNotifier. Please add the gems to your Gemfile as follows:

    gem 'honeybadger'
    gem 'rack'

Honeybadger is automatically configured using environment variables (e.g. HONEYBADGER_API_KEY). For a more detailed documentation please have a look at [their instructions](http://docs.honeybadger.io/collection/7-getting-started).

    require 'denouncer'

    Denouncer.configure(
      application_name: "my_app",
      notifier: :honeybadger
    )

#### AirbrakeNotifier

For more information on airbrake please refer to their [github repo](https://github.com/airbrake/airbrake).

#### !!!ATTENTION

The airbrake gem is required for the AirbrakeNotifier. Please add the gem to your Gemfile as follows:

    gem 'airbrake'


##### Airbrake Usage

    require 'denouncer'

    Denouncer.configure(
      application_name: "my_app",
      notifier: :airbrake,
      api_key: 'my_key'
    )

#### Multiple notifier configuration

Since version 0.4.0 denouncer supports parallel usage of multiple notifiers.
All exception notifications will be send to all configured notifiers.
The example below configures the amqp and smtp notifiers in parallel.

    require 'denouncer'

    Denouncer.configure(
      {
        application_name: "my_app",
        notifiers: [:smtp, :amqp],
        configurations: {
          smtp: {
            port: 1025,
            server: "localhost",
            sender: "noreply@example.com",
            recipients: ['usera@example.com', 'userb@example.com']
          },
          amqp: {
            port: 5672,
            server: "localhost",
            vhost: "/",
            username: "guest",
            password: "guest",
            message_queue: "my_app.errors"
          }
        }
      }
    )

## Usage

### Error notification

The example below shows a basic usage pattern for denouncer notifications.
Catch exceptions, then use denouncer's notify function and then re-raise the error again.

    begin
      1/0
    rescue => err
      Denouncer.notify err, { test: "my metadata 1", test2: "my metadata 2" }
      raise err
    end

or

    begin
      1/0
    rescue => err
      Denouncer.notify! err, { test: "my metadata 1", test2: "my metadata 2" }
    end

The metadata is optional and defaults to nil.

### Information notification

    Denouncer.info 'This contains lots of valuable information :)', { t1: "metadata 1", t2: "metadata 2" }

## Test Suite

    bundle exec rspec

## Architecture overview

[This](https://docs.google.com/drawings/d/16DaQhsAwcr-5zlguhKGwigpdNpOgO4-IXssLst7zlUM/edit?usp=sharing) illustration shows the basic architecture of the denouncer gem.

## TODOs

* Implement better test coverage

## Contributing

1. Fork it ( https://github.com/[my-github-username]/denouncer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## How to add a new notfier?

    # Copy the console notifier as base
    cp lib/denouncer/notifiers/console_notifier.rb lib/denouncer/notifiers/<name>_notifier.rb

    # add your notifier to the module
    vim lib/denouncer/notifiers.rb

    # adjust the notifier as needed
    # implement name, set_configuration! and notify methods
    vim lib/denouncer/notifiers/<name>_notifier.rb

    # add a section for the notifier to the documentation
    vim README.md

    # follow the instructions above (Contributing)
