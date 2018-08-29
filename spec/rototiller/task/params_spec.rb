require "spec_helper"

module Rototiller
  module Task
    describe RototillerParam do
      it "default message returns empty string" do
        expect(described_class.new.message).to eq("")
      end
      it "fails when trying to set a message on the root class instance" do
        expect{ described_class.new.message="blah" }.to raise_error(NoMethodError)
      end
    end
  end
end
