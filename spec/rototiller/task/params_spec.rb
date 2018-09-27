require "spec_helper"

module Rototiller
  module Task
    describe RototillerParam do
      it "default message returns empty string" do
        expect(described_class.new.message).to eq("")
      end
      it "fails when trying to set a message on the root class instance" do
        expect { described_class.new.message = "blah" }.to raise_error(NoMethodError)
      end
      context "#parent_name=" do
        let(:param) { described_class.new }
        it "sets @parent_name" do
          param.parent_name = "superkoolname"
          expect param.parent_name.to eq("superkoolname")
        end
        it "protects against illegal env_vars" do
          # raise ArgumentError.new(message) unless char =~ /[a-zA-Z]|\d|_/
          # no hyphens
          expect { param.parent_name = "-" }.to raise_error(ArgumentError)
          # no special chars
          expect { param.parent_name = "%" }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
