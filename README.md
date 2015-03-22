# TODO: READ THIS!!!!!!!!!!!!!!!!!!!!!
## http://www.tutorialspoint.com/ruby/ruby_sending_email.htm

# Exceptionist

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'exceptionist'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install exceptionist

## Configuration

    Exceptionist.configure({ application_name: "my_app", notifier: :smtp, port: 1025, server: "localhost", sender: "me@afsa.de", recipients: ['bla@bla.de', 'test@t.de'] })

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
