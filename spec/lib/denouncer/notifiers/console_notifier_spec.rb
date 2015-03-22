require 'spec_helper'

describe Denouncer::Notifiers::ConsoleNotifier do
  let(:config) { { application_name: "my_app" } }
  let(:notifier) { Denouncer::Notifiers::ConsoleNotifier.new config }

  describe "#set_configuration!" do
    it "should return the options" do
      conf = notifier.set_configuration! config
      expect(conf).to eq config
    end
  end

  describe "#notify" do
    it "should call puts" do
      expect_any_instance_of(Object).to receive(:puts).at_least(:once)
      notifier.notify(StandardError.new("Test"))
    end
  end
end
