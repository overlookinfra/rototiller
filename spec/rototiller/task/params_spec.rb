require "spec_helper"

module Rototiller
  module Task
    describe RototillerParam do
      context "#message" do
        it 'returns ""' do
          expect(described_class.new.message).to eq("")
        end
      end
    end
  end
end
