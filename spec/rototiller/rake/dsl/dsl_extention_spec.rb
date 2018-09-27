require "spec_helper"
require "stringio"

module Rake
  describe DSL do
    subject { Object.new.extend(Rake::DSL) }

    shared_examples "rototiller_task" do
      it "should create a rototiller task" do
        expect { @r = subject.rototiller_task name }.not_to raise_error
        expect(@r).to be_a(Rototiller::Task::RototillerTask)
        expect(@r.name).to eq(name)
      end
    end

    context "with just a name" do
      let(:name) { :foo }
      it_behaves_like "rototiller_task"
    end

    context "with name and dependencies" do
      let(:name) { { foo: %i[bar baz] } }
      it_behaves_like "rototiller_task"
    end
  end
end
