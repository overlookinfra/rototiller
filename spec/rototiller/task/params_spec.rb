require 'spec_helper'

module Rototiller
  module Task

    describe RototillerParam do
      context '#message' do
        it 'returns ""' do
          expect(described_class.new.message).to eq('')
        end
      end
      context '#parent_name=' do
        let (:param) {described_class.new}
        it 'sets @parent_name' do
          param.parent_name = 'superkoolname'
          expect(param.parent_name).to eq('superkoolname')
        end
        it 'protects against illegal env_vars' do
          #raise ArgumentError.new(message) unless char =~ /[a-zA-Z]|\d|_/
          # no hyphens
          expect{ param.parent_name = '-' }.to raise_error(ArgumentError)
          # no special chars
          expect{ param.parent_name = '%' }.to raise_error(ArgumentError)
        end
      end
    end

  end
end
