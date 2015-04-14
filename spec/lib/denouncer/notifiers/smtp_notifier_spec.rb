require 'spec_helper'

describe Denouncer::Notifiers::SmtpNotifier do
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
  let(:port) { 1025 }
  let(:domain) { 'localhost' }
  let(:username) { nil }
  let(:password) { nil }
  let(:authtype) { nil }
  let(:config) do
    {
      application_name: app_name,
      notifier: :smtp,
      port: port,
      server: server,
      sender: "noreply@example.com",
      recipients: ['usera@example.com', 'userb@example.com'],
      domain: domain,
      username: username,
      password: password,
      authtype: authtype
    }
  end

  describe "initialize" do
    context "valid configuration" do
      it "should set the configuration" do
        notifier = Denouncer::Notifiers::SmtpNotifier.new config
        expect(notifier.config).to eq config
      end
    end
  end

  describe "notify" do
    let(:notifier) { Denouncer::Notifiers::SmtpNotifier.new config }

    it "should start a SMTP connection" do
      expect(Net::SMTP).to receive(:start).with(server, port, domain, username, password, authtype)
      notifier.notify(error, { test: "abc" })
    end
  end

  describe "set_configuration!" do
    let(:notifier) { Denouncer::Notifiers::SmtpNotifier.new config }

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

      context "no sender" do
        let(:invalid) do
          config.delete(:sender)
          config
        end

        it "should raise an error" do
          expect { notifier.set_configuration! invalid }.to raise_error
        end
      end

      context "no recipients array" do
        let(:invalid) do
          config.delete(:recipients)
          config
        end

        it "should raise an error" do
          expect { notifier.set_configuration! invalid }.to raise_error
        end
      end
    end
  end

  describe "#generate_error_text_message" do
    let(:notifier) { Denouncer::Notifiers::SmtpNotifier.new config }
    let(:metadata_var) { "HASHVAR123" }
    let(:metadata) { { hash_var: metadata_var } }

    it "should generate a text message" do
      msg = notifier.send(:generate_error_text_message, error, metadata)
      expect(msg).to be_kind_of String
    end

    it "should contain the error message" do
      msg = notifier.send(:generate_error_text_message, error, metadata)
      expect(msg).to match error.message
    end

    it "should contain the error class" do
      msg = notifier.send(:generate_error_text_message, error, metadata)
      expect(msg).to match error.class.name
    end

    it "should contain the application_name" do
      msg = notifier.send(:generate_error_text_message, error, metadata)
      expect(msg).to match app_name
    end

    it "should contain the metadata hash" do
      msg = notifier.send(:generate_error_text_message, error, metadata)
      expect(msg).to match metadata_var
    end
  end
end
