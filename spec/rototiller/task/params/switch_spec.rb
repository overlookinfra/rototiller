require "spec_helper"

module Rototiller
  module Task
    # use each of these for the objects passed from it_behaves_like below
    #   (each of switch from hash and from block)
    # rubocop:disable Metrics/BlockLength
    shared_examples "a Switch object" do
      before(:each) do
        # stub out all the PRY env use, or the mocks for ENV below will break pry
        pryrc = ENV["PRYRC"]
        disable_pry = ENV["DISABLE_PRY"]
        home = ENV["HOME"]
        ansicon = ENV["ANSICON"]
        term = ENV["TERM"]
        pager = ENV["PAGER"]
        lines = ENV["LINES"]
        bundle_major_deprecations = ENV["BUNDLE_MAJOR_DEPRECATIONS"]
        allow(ENV).to receive(:[]).with("PRYRC").and_return(pryrc)
        allow(ENV).to receive(:[]).with("DISABLE_PRY").and_return(disable_pry)
        allow(ENV).to receive(:[]).with("HOME").and_return(home)
        allow(ENV).to receive(:[]).with("ANSICON").and_return(ansicon)
        allow(ENV).to receive(:[]).with("TERM").and_return(term)
        allow(ENV).to receive(:[]).with("PAGER").and_return(pager)
        allow(ENV).to receive(:[]).with("LINES").and_return(lines)
        allow(ENV).to receive(:[]).with("BUNDLE_MAJOR_DEPRECATIONS")
                                  .and_return(bundle_major_deprecations)

        @switch_name = random_string
        @args = { name: @switch_name }
        @block = proc do |b|
          b.name = @switch_name
        end
      end

      describe "#name" do
        it "can directly set name" do
          expect { switch.name = "wah" }.not_to raise_error
          expect(switch.name).to eq("wah")
        end
        it "returns the name" do
          expect(switch.name).to eq(@switch_name)
        end
      end

      describe "#to_str" do
        it "returns the name" do
          expect(switch.to_s).to eq(@switch_name.to_s)
        end
        # the rest of these perms are covered above, no need to repeat here
        it "can override switch name with env_var" do
          # set env first, or switch might not have it in time
          allow(ENV).to receive(:[]).with("BLAH").and_return("my_shiny_new_switch")
          switch.add_env(name: "BLAH")
          expect(switch.to_s).to eq("my_shiny_new_switch")
        end
      end

      describe "#safe_print" do
        it "is the same as to_s when values are not sensitive" do
          expect(switch.safe_print).to eq(switch.to_s)
        end
        # the rest of these perms are covered above, no need to repeat here
        it "is the same as to_s when overridden values are not senstive" do
          # set env first, or switch might not have it in time
          allow(ENV).to receive(:[]).with("BLAH").and_return("my_shiny_new_switch")
          switch.add_env(name: "BLAH")
          expect(switch.safe_print).to eq(switch.to_s)
        end
        it "redacts the name when senstive" do
          # set env first, or command might not have it in time
          allow(ENV).to receive(:[]).with("BLAH").and_return("my_shiny_new_switch")
          switch.add_env_sensitive(name: "BLAH")
          expect(switch.safe_print).to eq("[REDACTED]")
        end
      end

      it "fails when trying to set a message on a Switch" do
        expect { switch.message = "blah" }.to raise_error(NoMethodError)
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
