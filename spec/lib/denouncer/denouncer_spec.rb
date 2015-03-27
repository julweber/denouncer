require 'spec_helper'

describe Denouncer do
  let(:app_name) { "MyApplication" }
  let(:notifier_configuration) do
    { application_name: app_name, notifier: :console }
  end

  let(:multiple_notifier_configuration) do
    {
      application_name: app_name,
      notifiers: [:console, :console],
      configurations: {
        console: {
        }
      }
    }
  end

  let(:error) do
    StandardError.new("Test")
  end
  let(:metadata) do
    { var1: "abc" }
  end

  before do
    Denouncer.reset_configuration
  end

  describe ".configure" do
    let(:new_configuration) do
      { application_name: "TestAppThing", notifier: :console, extra: "abc" }
    end

    context "configured" do
      before do
        Denouncer.configure notifier_configuration
      end

      it "should override the configuration" do
        Denouncer.configure new_configuration
        expect(Denouncer.config).to eq new_configuration
      end

      it "should initialize notifiers" do
        Denouncer.configure new_configuration
        expect(Denouncer.send(:notifiers)).not_to be_nil
        expect(Denouncer.send(:notifiers)).to be_instance_of Array
      end
    end

    context "unconfigured" do
      it "should set the given configuration" do
        Denouncer.configure new_configuration
        expect(Denouncer.config).to eq new_configuration
      end

      it "should initialize notifiers" do
        Denouncer.configure new_configuration
        expect(Denouncer.send(:notifiers)).not_to be_nil
        expect(Denouncer.send(:notifiers)).to be_instance_of Array
      end
    end

    context "invalid config hash" do
      context "no :application_name setting given" do
        let(:invalid) do
          { notifier: :console, extra: "abc" }
        end

        it "should raise an error" do
          expect { Denouncer.configure invalid }.to raise_error
        end
      end

      context "no hash given" do
        let(:invalid) do
          "Invalid String"
        end

        it "should raise an error" do
          expect { Denouncer.configure invalid }.to raise_error
        end
      end

      context "nil given" do
        it "should raise an error" do
          expect { Denouncer.configure nil }.to raise_error
        end
      end

      context "invalid notifier setting given" do
        let(:invalid) do
          { application_name: "TestAppThing", notifier: :not_existing }
        end

        it "should raise an error" do
          expect { Denouncer.configure invalid }.to raise_error
        end
      end
    end

    context 'multiple notifiers' do
      context 'unconfigured' do
        it 'should initialize the configuration' do
          Denouncer.configure multiple_notifier_configuration
          expect(Denouncer.config).not_to be_nil
        end

        it "should initialize notifiers" do
          Denouncer.configure multiple_notifier_configuration
          expect(Denouncer.send(:notifiers)).to be_instance_of Array
          expect(Denouncer.send(:notifiers).count).to eq multiple_notifier_configuration[:notifiers].count
        end
      end

      context 'invalid settings hash' do
        context ':notifier and :notifiers setting provided' do
          let(:invalid) do
            {
              application_name: "TestAppThing",
              notifier: :amqp,
              notifiers: [:amqp,:smtp]
            }
          end

          it 'should raise an error' do
            expect { Denouncer.configure invalid }.to raise_error
          end
        end

        context 'without :configurations sub-hash' do
          let(:invalid) do
            {
              application_name: "TestAppThing",
              notifiers: [:amqp,:smtp]
            }
          end

          it 'should raise an error' do
            expect { Denouncer.configure invalid }.to raise_error
          end
        end

      end
    end
  end

  describe ".is_configured?" do
    context "configured" do
      before do
        Denouncer.configure notifier_configuration
      end

      it "should return true" do
        expect(Denouncer.is_configured?).to be_truthy
      end
    end

    context "unconfigured" do
      it "should return false" do
        expect(Denouncer.is_configured?).to be_falsey
      end
    end
  end

  describe ".reset_configuration" do
    before do
      Denouncer.configure notifier_configuration
    end

    it "should set the configuration to nil" do
      Denouncer.reset_configuration
      expect(Denouncer.config).to be_nil
      expect(Denouncer.is_configured?).to be_falsey
    end
  end

  describe ".config" do
    context "configured" do
      context "single notifier" do
        before do
          Denouncer.configure notifier_configuration
        end

        it "should return the notifier's configuration" do
          notifier = Denouncer.send(:notifiers).first
          expect(Denouncer.config).to eq notifier.config
        end
      end

      context 'multiple notifiers' do
        before do
          Denouncer.configure multiple_notifier_configuration
        end

        it "should return a hash of configurations" do
          notifiers = Denouncer.send(:notifiers)
          notifier_symbols = notifiers.map { |n| n.name.to_sym }
          expected_config = {
            application_name: app_name,
            notifiers: notifier_symbols,
            configurations: {
              console: notifiers.first.config
            }
          }
          expect(Denouncer.config).to eq expected_config
        end
      end
    end

    context "unconfigured" do
      it "should return nil" do
        expect(Denouncer.config).to be_nil
      end
    end
  end

  describe ".notify!" do
    context "single notifier" do
      before do
        Denouncer.configure notifier_configuration
      end

      it "should call it's notifier's notify method and raise the given error" do
        notifiers = Denouncer.send(:notifiers)
        notifiers.each do |notif|
          expect(notif).to receive(:notify).with(error, metadata)
        end
        expect { Denouncer.notify! error, metadata }.to raise_error error
      end
    end

    context "multiple notifiers" do
      before do
        Denouncer.configure multiple_notifier_configuration
      end

      it "should call it's notifier's notify method and raise the given error" do
        notifiers = Denouncer.send(:notifiers)
        notifiers.each do |notif|
          expect(notif).to receive(:notify).with(error, metadata)
        end
        expect { Denouncer.notify! error, metadata }.to raise_error error
      end
    end
  end

  describe ".notify" do
    context "single notifier configured" do
      context "configured" do
        before do
          Denouncer.configure notifier_configuration
        end

        it "should call it's notifier's notify method" do
          notifiers = Denouncer.send(:notifiers)
          notifiers.each do |notif|
            expect(notif).to receive(:notify).with(error, metadata)
          end
          Denouncer.notify error, metadata
        end

        it "should return true" do
          expect(Denouncer.notify error).to be_truthy
        end
      end

      context "unconfigured" do
        it "should return false" do
          expect(Denouncer.notify error).to be_falsey
        end
      end
    end

    context "multiple notifiers configured" do
      before do
        Denouncer.configure multiple_notifier_configuration
      end

      it "should call all configured notifiers' notify method" do
        notifiers = Denouncer.send(:notifiers)
        notifiers.each do |notif|
          expect(notif).to receive(:notify).with(error, metadata)
        end
        Denouncer.notify error, metadata
      end

      it "should return true" do
        expect(Denouncer.notify error).to be_truthy
      end
    end
  end
end
