require 'spec_helper'

describe Exceptionist::Notifiers::SmtpNotifier do
  let(:error) do
    StandardError.new("Test")
  end
  let(:server) { 'localhost' }
  let(:port) { 1025 }
  let(:domain) { 'localhost' }
  let(:username) { nil }
  let(:password) { nil }
  let(:authtype) { nil }
  let(:config) do
    {
      application_name: "my_app",
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
        notifier = Exceptionist::Notifiers::SmtpNotifier.new config
        expect(notifier.config).to eq config
      end
    end
  end

  describe "notify" do
    let(:notifier) { Exceptionist::Notifiers::SmtpNotifier.new config }

    it "should start a SMTP connection" do
      expect(Net::SMTP).to receive(:start).with(server, port, domain, username, password, authtype)
      notifier.notify(error, { test: "abc" })
    end
  end

  describe "set_configuration!" do
    let(:notifier) { Exceptionist::Notifiers::SmtpNotifier.new config }

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
end
