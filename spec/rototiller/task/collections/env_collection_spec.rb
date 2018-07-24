require "spec_helper"

module Rototiller
  module Task
    describe EnvCollection do
      context "#allowed_class" do
        it "allows only EnvVars" do
          expect(described_class.new.allowed_class).to eql(EnvVar)
        end
      end

      context "#last" do
        let(:collection) { described_class.new }
        it "returns nil when collection empty" do
          expect(collection.last).to be_nil
        end
        it "returns nil when solitary EnvVar is empty" do
          allow(ENV).to receive(:[]).with("BLAH").and_return(nil)
          collection.push EnvVar.new(name: "BLAH")
          expect(collection.last).to be_nil
        end
        it "returns nil when two EnvVars are empty" do
          allow(ENV).to receive(:[]).with("BLAH").and_return(nil)
          allow(ENV).to receive(:[]).with("BLAH2").and_return(nil)
          collection.push EnvVar.new(name: "BLAH")
          collection.push EnvVar.new(name: "BLAH2")
          expect(collection.last).to be_nil
        end
        it "returns value when solitary EnvVar has a value" do
          allow(ENV).to receive(:[]).with("BLAH").and_return("success")
          collection.push EnvVar.new(name: "BLAH")
          expect(collection.last).to eq "success"
        end
        it "returns value when first EnvVar has value and rest empty" do
          allow(ENV).to receive(:[]).with("BLAH").and_return("success")
          allow(ENV).to receive(:[]).with("BLAH2").and_return(nil)
          collection.push EnvVar.new(name: "BLAH")
          collection.push EnvVar.new(name: "BLAH2")
          expect(collection.last).to eq "success"
        end
        it "returns correct value when multiple nil and EnvVars exist" do
          allow(ENV).to receive(:[]).with("BLAH").and_return("fail")
          allow(ENV).to receive(:[]).with("BLAH2").and_return(nil)
          allow(ENV).to receive(:[]).with("BLAH3").and_return("success")
          allow(ENV).to receive(:[]).with("BLAH4").and_return(nil)
          collection.push EnvVar.new(name: "BLAH")
          collection.push EnvVar.new(name: "BLAH2")
          collection.push EnvVar.new(name: "BLAH3")
          collection.push EnvVar.new(name: "BLAH4")
          expect(collection.last).to eq "success"
        end
      end
    end
  end
end
