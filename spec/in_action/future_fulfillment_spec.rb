require "spec_helper"

module ActiveRecord::Futures
  describe "Future fulfillment" do
    subject { FutureRegistry }

    context "when futurizing a relation" do
      let!(:future_result) { Post.where(title: "Some post").future }
      let!(:future) { future_result.send(:future_execution) }

      its(:all) { should have(1).future }

      context "the future" do
        specify { future.should_not be_fulfilled }
      end

      context "and executing it" do
        before { future_result.to_a }

        its(:all) { should have(0).futures }

        context "the future" do
          subject { future }

          it(nil, :supporting_adapter) { should be_fulfilled }
          it(nil, :not_supporting_adapter) { should_not be_fulfilled }
        end
      end
    end

    context "when futurizing two relations" do
      let!(:future_result) { Post.where(title: "Some post").future }
      let!(:future) { future_result.send(:future_execution) }
      let!(:another_future_result) { User.where(name: "Lenny").future }
      let!(:another_future) { another_future_result.send(:future_execution) }

      its(:all) { should have(2).futures }

      context "the first relation future" do
        specify { future.should_not be_fulfilled }
      end

      context "the other relation future" do
        specify { another_future.should_not be_fulfilled }
      end

      context "and executing one of them" do
        before { future_result.to_a }

        its(:all) { should have(0).futures }

        context "the first relation future" do
          specify(nil, :supporting_adapter) { future.should be_fulfilled }
          specify(nil, :not_supporting_adapter) { future.should_not be_fulfilled }
        end

        context "the other relation future" do
          specify(nil, :supporting_adapter) { another_future.should be_fulfilled }
          specify(nil, :not_supporting_adapter) { another_future.should_not be_fulfilled }
        end
      end

      context "and executing another non futurized relation" do
        let!(:normal_relation) { User.where(name: "John") }
        before { normal_relation.to_a }

        its(:all) { should have(2).futures }

        context "the first relation future" do
          specify { future.should_not be_fulfilled }
        end

        context "the other relation future" do
          specify { another_future.should_not be_fulfilled }
        end
      end
    end
  end
end