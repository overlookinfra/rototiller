require "spec_helper"

module Rototiller
  module Task
    # rubocop:disable Metrics/BlockLength
    describe OptionCollection do
      context "#allowed_class" do
        it "allows only Options" do
          expect(described_class.new.allowed_class).to eql(Option)
        end
      end

      context "#to_s" do
        let(:collection) { described_class.new }
        it "is nil when collection empty" do
          expect(collection.to_s).to eq nil
        end
        it "is emp" do
          collection.push Option.new(name: "")
          expect(collection.to_s).to eq ""
        end
        it "is empty when collection members nil" do
          collection.push Option.new(name: nil)
          expect(collection.to_s).to eq ""
        end
        it "stringifies value when solitary has a value" do
          collection.push Option.new(name: "BLAH")
          expect(collection.to_s).to eq "BLAH"
        end
        it "stringifies value when first has value and rest empty" do
          collection.push Option.new(name: "BLAH")
          collection.push Option.new(name: "")
          expect(collection.to_s).to eq "BLAH "
        end
        it "stringifies value when first has value and rest nil" do
          collection.push Option.new(name: "BLAH")
          collection.push Option.new(name: nil)
          expect(collection.to_s).to eq "BLAH "
        end
        it "stringifies values when they have values" do
          collection.push Option.new(name: "BLAH")
          collection.push Option.new(name: "other")
          expect(collection.to_s).to eq "BLAH other"
        end

        context "with argument" do
          let(:argument) { random_string }

          it "stringifies" do
            collection.push Option.new(name: "--foo", add_argument: { name: argument })
            expect(collection.to_s).to eq("--foo #{argument}")
          end

          context "with two options" do
            it "stringifies" do
              collection.push Option.new(name: "--baz", add_argument: { name: argument })
              collection.push Option.new(name: "--bar", add_argument: { name: argument })
              expect(collection.to_s).to eq("--baz #{argument} --bar #{argument}")
            end
          end
        end
      end
    end
  end
end
