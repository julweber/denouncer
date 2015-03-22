require 'spec_helper'

describe Denouncer do
  let(:notifier_configuration) do
    { application_name: "MyApplication", notifier: :console }
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

      it "should initialize a notifier" do
        Denouncer.configure new_configuration
        expect(Denouncer.send(:notifier)).not_to be_nil
      end
    end

    context "unconfigured" do
      it "should set the given configuration" do
        Denouncer.configure new_configuration
        expect(Denouncer.config).to eq new_configuration
      end

      it "should initialize a notifier" do
        Denouncer.configure new_configuration
        expect(Denouncer.send(:notifier)).not_to be_nil
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

    it "should set the notifier to nil" do
      Denouncer.reset_configuration
      expect(Denouncer.config).to be_nil
      expect(Denouncer.is_configured?).to be_falsey
    end
  end

  describe ".config" do
    context "configured" do
      before do
        Denouncer.configure notifier_configuration
      end

      it "should return the notifier's configuration" do
        notifier = Denouncer.send(:notifier)
        expect(Denouncer.config).to eq notifier.config
      end
    end

    context "unconfigured" do
      it "should return nil" do
        expect(Denouncer.config).to be_nil
      end
    end
  end

  describe ".notify" do
    context "configured" do
      before do
        Denouncer.configure notifier_configuration
      end

      it "should call it's notifiers notify method" do
        notifier = Denouncer.send(:notifier)
        expect(notifier).to receive(:notify).with(error, metadata)
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
end
