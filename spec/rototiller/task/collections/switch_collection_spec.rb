require "spec_helper"

module Rototiller
  module Task
    # rubocop:disable Metrics/BlockLength
    describe SwitchCollection do
      context "#allowed_class" do
        it "allows only Switches" do
          expect(described_class.new.allowed_class).to eql(Switch)
        end
      end

      context "#to_s" do
        let(:collection) { described_class.new }
        it "is nil when collection empty" do
          expect(collection.to_s).to eq nil
        end
        it "is empty when collection members empty" do
          collection.push Switch.new(name: "")
          expect(collection.to_s).to eq ""
        end
        it "is empty when collection members nil" do
          collection.push Switch.new(name: nil)
          expect(collection.to_s).to eq ""
        end
        it "stringifies value when solitary has a value" do
          collection.push Switch.new(name: "BLAH")
          expect(collection.to_s).to eq "BLAH"
        end
        it "stringifies value when first has value and rest empty" do
          collection.push Switch.new(name: "BLAH")
          collection.push Switch.new(name: "")
          expect(collection.to_s).to eq "BLAH "
        end
        it "stringifies value when first has value and rest nil" do
          collection.push Switch.new(name: "BLAH")
          collection.push Switch.new(name: nil)
          expect(collection.to_s).to eq "BLAH "
        end
        it "stringifies values when they have values" do
          collection.push Switch.new(name: "BLAH")
          collection.push Switch.new(name: "other")
          expect(collection.to_s).to eq "BLAH other"
        end
      end
    end
  end
end
