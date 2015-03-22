require 'spec_helper'

describe Exceptionist do
  let(:notifier_configuration) do
    { application_name: "MyApplication", notifier: :console }
  end
  let(:error) do
    StandardError.new("Test")
  end

  before do
    Exceptionist.reset_configuration
  end

  describe ".configure" do
    let(:new_configuration) do
      { application_name: "TestAppThing", notifier: :console, extra: "abc" }
    end

    context "configured" do
      before do
        Exceptionist.configure notifier_configuration
      end

      it "should override the configuration" do
        Exceptionist.configure new_configuration
        expect(Exceptionist.config).to eq new_configuration
      end

      it "should initialize a notifier" do
        Exceptionist.configure new_configuration
        expect(Exceptionist.send(:notifier)).not_to be_nil
      end
    end

    context "unconfigured" do
      it "should set the given configuration" do
        Exceptionist.configure new_configuration
        expect(Exceptionist.config).to eq new_configuration
      end

      it "should initialize a notifier" do
        Exceptionist.configure new_configuration
        expect(Exceptionist.send(:notifier)).not_to be_nil
      end
    end

    context "invalid config hash" do
      context "no :application_name setting given" do
        let(:invalid) do
          { notifier: :console, extra: "abc" }
        end

        it "should raise an error" do
          expect { Exceptionist.configure invalid }.to raise_error
        end
      end

      context "no hash given" do
        let(:invalid) do
          "Invalid String"
        end

        it "should raise an error" do
          expect { Exceptionist.configure invalid }.to raise_error
        end
      end

      context "nil given" do
        it "should raise an error" do
          expect { Exceptionist.configure nil }.to raise_error
        end
      end

      context "invalid notifier setting given" do
        let(:invalid) do
          { application_name: "TestAppThing", notifier: :not_existing }
        end

        it "should raise an error" do
          expect { Exceptionist.configure invalid }.to raise_error
        end
      end
    end
  end

  describe ".is_configured?" do
    context "configured" do
      before do
        Exceptionist.configure notifier_configuration
      end

      it "should return true" do
        expect(Exceptionist.is_configured?).to be_truthy
      end
    end

    context "unconfigured" do
      it "should return false" do
        expect(Exceptionist.is_configured?).to be_falsey
      end
    end
  end

  describe ".reset_configuration" do
    before do
      Exceptionist.configure notifier_configuration
    end

    it "should set the notifier to nil" do
      Exceptionist.reset_configuration
      expect(Exceptionist.config).to be_nil
      expect(Exceptionist.is_configured?).to be_falsey
    end
  end

  describe ".config" do
    context "configured" do
      before do
        Exceptionist.configure notifier_configuration
      end

      it "should return the notifier's configuration" do
        notifier = Exceptionist.send(:notifier)
        expect(Exceptionist.config).to eq notifier.config
      end
    end

    context "unconfigured" do
      it "should return nil" do
        expect(Exceptionist.config).to be_nil
      end
    end
  end

  describe ".notify" do
    context "configured" do
      before do
        Exceptionist.configure notifier_configuration
      end

      it "should call it's notifiers notify method" do
        notifier = Exceptionist.send(:notifier)
        expect(notifier).to receive(:notify)
        Exceptionist.notify error
      end
    end

    context "unconfigured" do
      it "should raise an error" do
        expect { Exceptionist.notify error }.to raise_error
      end
    end
  end
end
