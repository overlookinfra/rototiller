require 'spec_helper'

module Rototiller
  module Task

    # use each of these for the objects passed from it_behaves_like below
    #   (each of switch from hash and from block)
    shared_examples "a Switch object" do
      before(:each) do
        # stub out all the PRY env use, or the mocks for ENV below will break pry
        pryrc = ENV['PRYRC']
        disable_pry = ENV['DISABLE_PRY']
        home = ENV['HOME']
        ansicon = ENV['ANSICON']
        term = ENV['TERM']
        pager = ENV['PAGER']
        lines = ENV['LINES']
        bundle_major_deprecations = ENV['BUNDLE_MAJOR_DEPRECATIONS']
        allow(ENV).to receive(:[]).with('PRYRC').and_return(pryrc)
        allow(ENV).to receive(:[]).with('DISABLE_PRY').and_return(disable_pry)
        allow(ENV).to receive(:[]).with('HOME').and_return(home)
        allow(ENV).to receive(:[]).with('ANSICON').and_return(ansicon)
        allow(ENV).to receive(:[]).with('TERM').and_return(term)
        allow(ENV).to receive(:[]).with('PAGER').and_return(pager)
        allow(ENV).to receive(:[]).with('LINES').and_return(lines)
        allow(ENV).to receive(:[]).with('BUNDLE_MAJOR_DEPRECATIONS').and_return(bundle_major_deprecations)

        @switch_name  = random_string
        @args = {:name => @switch_name, :message => 'killer message'}
        @block = Proc.new { |b| b.name = @switch_name; b.message = 'killer message'}
      end

      describe '#name' do
        it 'can directly set name' do
          expect{ switch.name = 'wah' }.not_to raise_error
          expect( switch.name ).to eq('wah')
        end
        it 'returns the name' do
          expect(switch.name).to eq(@switch_name)
        end
      end

      describe '#add_env' do
        it 'can not directly set env_vars' do
          expect{ switch.env_vars << 'wah' }.to raise_error(NoMethodError)
        end
        describe 'as hash' do
          it 'does not override switch name with empty env_var' do
            # set env first, or switch might not have it in time
            allow(ENV).to receive(:[]).with('BLAH').and_return(nil)
            switch.add_env({:name => 'BLAH'})
            expect(switch.name).to eq(@switch_name)
          end
          it 'can override switch name with env_var' do
            # set env first, or switch might not have it in time
            allow(ENV).to receive(:[]).with('BLAH').and_return('my_shiny_new_switch')
            switch.add_env({:name => 'BLAH'})
            expect(switch.name).to eq('my_shiny_new_switch')
          end
          it 'can override switch name with multiple env_var' do
            # set env first, or switch might not have it in time
            allow(ENV).to receive(:[]).with('ENV1').and_return('wrong')
            allow(ENV).to receive(:[]).with('ENV2').and_return('right')
            switch.add_env({:name => 'ENV1'})
            switch.add_env({:name => 'ENV2'})
            expect(switch.name).to eq('right')
          end
          it 'can override switch name with multiple env_var and one not set' do
            allow(ENV).to receive(:[]).with('ENV1').and_return('rite')
            allow(ENV).to receive(:[]).with('ENV2').and_return(nil)
            switch.add_env({:name => 'ENV1'})
            switch.add_env({:name => 'ENV2'})
            expect(switch.name).to eq('rite')
          end
          it 'can override switch name with multiple env_var and first not set' do
            allow(ENV).to receive(:[]).with('ENV1').and_return(nil)
            allow(ENV).to receive(:[]).with('ENV2').and_return('rite')
            switch.add_env({:name => 'ENV1'})
            switch.add_env({:name => 'ENV2'})
            expect(switch.name).to eq('rite')
          end
          it 'raises an error when supplied a bad key' do
            bad_key = :foo
            expect{ switch.add_env({bad_key => 'bar'})}.to raise_error(ArgumentError)
          end
        end
        describe 'as block' do
          it 'does not override switch name with empty env_var' do
            # set env first, or switch might not have it in time
            allow(ENV).to receive(:[]).with('BLAH').and_return(nil)
            switch.add_env { |e| e.name = 'BLAH' }
            expect(switch.name).to eq(@switch_name)
          end
          it 'can override switch name with env_var' do
            # set env first, or switch might not have it in time
            allow(ENV).to receive(:[]).with('BLAH').and_return('my_shiny_new_switch')
            switch.add_env { |e| e.name = 'BLAH' }
            expect(switch.name).to eq('my_shiny_new_switch')
          end
          it 'can override switch name with multiple env_var' do
            # set env first, or switch might not have it in time
            allow(ENV).to receive(:[]).with('ENV1').and_return('wrong')
            allow(ENV).to receive(:[]).with('ENV2').and_return('right')
            switch.add_env { |e| e.name = 'ENV1' }
            switch.add_env { |e| e.name = 'ENV2' }
            expect(switch.name).to eq('right')
          end
          it 'can override switch name with multiple env_var and one not set' do
            allow(ENV).to receive(:[]).with('ENV1').and_return('rite')
            allow(ENV).to receive(:[]).with('ENV2').and_return(nil)
            switch.add_env { |e| e.name = 'ENV1' }
            switch.add_env { |e| e.name = 'ENV2' }
            expect(switch.name).to eq('rite')
          end
          it 'can override switch name with multiple env_var and first not set' do
            allow(ENV).to receive(:[]).with('ENV1').and_return(nil)
            allow(ENV).to receive(:[]).with('ENV2').and_return('rite')
            switch.add_env { |e| e.name = 'ENV1' }
            switch.add_env { |e| e.name = 'ENV2' }
            expect(switch.name).to eq('rite')
          end
        end
      end

      describe '#to_str' do
        it 'returns the name' do
          expect(switch.to_s).to eq("#{@switch_name}")
        end
        # the rest of these perms are covered above, no need to repeat here
        it 'can override switch name with env_var' do
          # set env first, or switch might not have it in time
          allow(ENV).to receive(:[]).with('BLAH').and_return('my_shiny_new_switch')
          switch.add_env({:name => 'BLAH'})
          expect(switch.to_s).to eq("my_shiny_new_switch")
        end
      end

      describe '#message' do
        it 'returns the formatted message' do
          @formatted_message = 'killer message'
          expect(switch.message).to eq(@formatted_message + "\n")
        end
      end
    end

    describe Switch do
      it_behaves_like "a Switch object" do
        let(:switch)  { described_class.new(@args) }
      end
      it_behaves_like "a Switch object" do
        let(:switch)  { described_class.new(&@block) }
      end
    end

  end
end
