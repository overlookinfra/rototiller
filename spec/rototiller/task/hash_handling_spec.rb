require "spec_helper"
require "rototiller/task/hash_handling"

describe Rototiller::Task::HashHandling do
  before(:all) do
    class FakeParam
      include Rototiller::Task::HashHandling
      attr_accessor :name

      def initialize(args)
        send_hash_keys_as_methods_to_self(args)
      end

      def add_env(arg)
        @add_env = arg
      end
    end
  end

  it "should call the setter method if defined as attr_accessor" do
    args = { name: "foo" }
    expect { @param = FakeParam.new(args) }.not_to raise_error
    expect(@param.name).to eq("foo")
  end

  it "should call the getter method if defined as class method" do
    args = { add_env: { name: "bar" } }
    expect { @param = FakeParam.new(args) }.not_to raise_error
    expect(@param.instance_variable_get(:@add_env)).to eq(name: "bar")
  end

  it "should raise an error if method does not exist" do
    args = { nosuch: "baz" }
    expect { FakeParam.new(args) }.to raise_error { |error| expect(error).to be_a(ArgumentError) }
  end
end
