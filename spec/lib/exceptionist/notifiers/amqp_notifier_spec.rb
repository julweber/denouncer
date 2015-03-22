require 'spec_helper'

describe Exceptionist::Notifiers::AmqpNotifier do
  let(:error) do
    error = nil
    begin
      1/0
    rescue => err
      error = err
    end
    error
  end
  let(:app_name) { "my_app" }
  let(:server) { 'localhost' }
  let(:port) { 5672 }
  let(:username) { 'guest' }
  let(:password) { 'guest' }
  let(:vhost) { '/'}
  let(:message_queue) { 'my_app.errors' }
  let(:config) do
    {
      application_name: app_name,
      notifier: :amqp,
      port: port,
      server: server,
      vhost: vhost,
      username: username,
      password: password,
      message_queue: message_queue
    }
  end

  describe "initialize" do
    context "valid configuration" do
      it "should set the configuration" do
        notifier = Exceptionist::Notifiers::AmqpNotifier.new config
        expect(notifier.config).to eq config
      end
    end
  end

  describe "set_configuration!" do
    let(:notifier) { Exceptionist::Notifiers::AmqpNotifier.new config }

    context "valid configuration" do
      it "should not raise an error" do
        expect { notifier.set_configuration!(config) }.not_to raise_error
      end

      it "should return the options hash" do
        expect(notifier.set_configuration!(config)).to eq config
      end
    end

    context "invalid configuration" do
      context "no application_name" do
        let(:invalid) do
          config.delete(:application_name)
          config
        end

        it "should raise an error" do
          expect { notifier.set_configuration! invalid }.to raise_error
        end
      end
    end
  end

  describe "#generate_json_message" do
    let(:notifier) { Exceptionist::Notifiers::AmqpNotifier.new config }
    let(:metadata_var) { "HASHVAR123" }
    let(:metadata) { { hash_var: metadata_var } }

    it "should generate a json encoded message" do
      msg = notifier.send(:generate_json_message, error, metadata)
      expect(msg).to be_kind_of String
      expect { JSON.parse(msg) }.not_to raise_error
    end

    it "should contain the error message" do
      msg = notifier.send(:generate_json_message, error, metadata)
      parsed = JSON.parse(msg)
      expect(parsed["error_message"]).to match (error.message)
    end

    it "should contain the error class" do
      msg = notifier.send(:generate_json_message, error, metadata)
      parsed = JSON.parse(msg)
      expect(parsed["error_class"]).to eq (error.class.name)
    end

    it "should contain the application_name" do
      msg = notifier.send(:generate_json_message, error, metadata)
      parsed = JSON.parse(msg)
      expect(parsed["application_name"]).to eq app_name
    end

    it "should contain the metadata hash" do
      msg = notifier.send(:generate_json_message, error, metadata)
      parsed = JSON.parse(msg)
      expect(parsed["metadata"]).to be_kind_of Hash
      expect(parsed["metadata"]["hash_var"]).to eq metadata_var
    end

    it "should contain the backtrace" do
      msg = notifier.send(:generate_json_message, error, metadata)
      parsed = JSON.parse(msg)
      expect(parsed["error_backtrace"]).to be_kind_of Array
    end

    it "should contain the notification_time" do
      msg = notifier.send(:generate_json_message, error, metadata)
      parsed = JSON.parse(msg)
      expect(parsed["notification_time"]).not_to be_nil
    end
  end
end
