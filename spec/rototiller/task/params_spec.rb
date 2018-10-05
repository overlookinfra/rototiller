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
    end

    shared_examples "a RototillerParamWithEnv object" do
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

        @param_name = random_string
        @args = { name: @param_name }
        @block = proc do |b|
          b.name = @param_name
        end
      end

      describe "#add_env" do
        it "can not directly set env_vars" do
          expect { param.env_vars << "wah" }.to raise_error(NoMethodError)
        end
        describe "as hash" do
          it "does not override param name (#{@param_name}) with empty env_var" do
            # set env first, or param might not have it in time
            allow(ENV).to receive(:[]).with("BLAHZZZ").and_return(nil)
            param.add_env(name: "BLAHZZZ")
            expect(param.name).to eq(@param_name)
          end
          it "can override param name with env_var" do
            # set env first, or param might not have it in time
            allow(ENV).to receive(:[]).with("BLAH").and_return("my_shiny_new_param")
            param.add_env(name: "BLAH")
            expect(param.name).to eq("my_shiny_new_param")
          end
          it "can override param name with multiple env_var" do
            # set env first, or param might not have it in time
            allow(ENV).to receive(:[]).with("ENV1").and_return("wrong")
            allow(ENV).to receive(:[]).with("ENV2").and_return("right")
            param.add_env(name: "ENV1")
            param.add_env(name: "ENV2")
            expect(param.name).to eq("right")
          end
          it "can override param name with multiple env_var and one not set" do
            allow(ENV).to receive(:[]).with("ENV1").and_return("rite")
            allow(ENV).to receive(:[]).with("ENV2").and_return(nil)
            param.add_env(name: "ENV1")
            param.add_env(name: "ENV2")
            expect(param.name).to eq("rite")
          end
          it "can override param name with multiple env_var and first not set" do
            allow(ENV).to receive(:[]).with("ENV1").and_return(nil)
            allow(ENV).to receive(:[]).with("ENV2").and_return("rite")
            param.add_env(name: "ENV1")
            param.add_env(name: "ENV2")
            expect(param.name).to eq("rite")
          end
          it "raises an error when supplied a bad key" do
            bad_key = :foo
            expect { param.add_env(bad_key => "bar") }.to raise_error(ArgumentError)
          end
        end
        describe "as block" do
          it "does not override param name with empty env_var" do
            # set env first, or param might not have it in time
            allow(ENV).to receive(:[]).with("BLAH").and_return(nil)
            param.add_env { |e| e.name = "BLAH" }
            expect(param.name).to eq(@param_name)
          end
          it "can override param name with env_var" do
            # set env first, or param might not have it in time
            allow(ENV).to receive(:[]).with("BLAH").and_return("my_shiny_new_param")
            param.add_env { |e| e.name = "BLAH" }
            expect(param.name).to eq("my_shiny_new_param")
          end
          it "can override param name with multiple env_var" do
            # set env first, or param might not have it in time
            allow(ENV).to receive(:[]).with("ENV1").and_return("wrong")
            allow(ENV).to receive(:[]).with("ENV2").and_return("right")
            param.add_env { |e| e.name = "ENV1" }
            param.add_env { |e| e.name = "ENV2" }
            expect(param.name).to eq("right")
          end
          it "can override param name with multiple env_var and one not set" do
            allow(ENV).to receive(:[]).with("ENV1").and_return("rite")
            allow(ENV).to receive(:[]).with("ENV2").and_return(nil)
            param.add_env { |e| e.name = "ENV1" }
            param.add_env { |e| e.name = "ENV2" }
            expect(param.name).to eq("rite")
          end
          it "can override param name with multiple env_var and first not set" do
            allow(ENV).to receive(:[]).with("ENV1").and_return(nil)
            allow(ENV).to receive(:[]).with("ENV2").and_return("rite")
            param.add_env { |e| e.name = "ENV1" }
            param.add_env { |e| e.name = "ENV2" }
            expect(param.name).to eq("rite")
          end
        end
      end
    end
    describe RototillerParamWithEnv do
      it_behaves_like "a RototillerParamWithEnv object" do
        let(:param)  { described_class.new(@args) }
      end
      it_behaves_like "a RototillerParamWithEnv object" do
        let(:param)  { described_class.new(&@block) }
      end
    end
  end
end
