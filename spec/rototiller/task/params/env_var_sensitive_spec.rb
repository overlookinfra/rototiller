require "spec_helper"
require "rototiller/task/params/env_var_sensitive"

module Rototiller
  module Task
    # rubocop:disable Metrics/BlockLength
    describe EnvVarSensitive do
      ["ENV set", "ENV not set"].each do |env_set|
        context ", with #{env_set}:" do
          before(:each) do
            @var_name      = "VARNAME_#{(0...8).map { (65 + rand(26)).chr }.join}"
            @var_message   = "This is how you use #{@var_name}"
            @var_env_value = "VARENVVALUE_#{(0...8).map { (65 + rand(26)).chr }.join}"
            ENV[@var_name] = @var_env_value if env_set == "ENV set"

            args = { name: @var_name, message: @var_message }
            @env_var = described_class.new(args)

            if env_set == "ENV not set"
              @formatted_message = "\e[31m[E] required: \e[0m'#{@var_name}'; '#{@var_message}'"
              @expected_stop = true
            else
              @formatted_message = "\e[33m[I] \e[0m'#{@var_name}': using system: " \
                "'[REDACTED]'; '#{@var_message}'"
              @expected_stop = false
            end
          end

          describe ".var" do
            it "returns the var" do
              expect(@env_var.name).to eq(@var_name)
            end
          end

          describe ".message" do
            it "returns the formatted message" do
              expect(@env_var.message).to eq(@formatted_message + "\n")
            end
            it "does not include the sensitive value" do
              expect(@env_var.message).not_to match(@var_env_value)
            end
          end

          describe ".default" do
            it "fails" do
              expect { @env_var.default }.to raise_error(NoMethodError)
            end
          end

          describe ".stop" do
            it "knows if it should stop" do
              expect(@env_var.stop).to eq(@expected_stop)
            end
          end
        end
      end
    end
  end
end
