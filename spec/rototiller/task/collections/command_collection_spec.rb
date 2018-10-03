require "spec_helper"

module Rototiller
  module Task
    describe CommandCollection do
      context "#allowed_class" do
        it "allows only Command" do
          expect(described_class.new.allowed_class).to eql(Command)
        end
      end
    end
  end
end
