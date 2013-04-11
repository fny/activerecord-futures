require "spec_helper"

module ActiveRecord::Futures
  describe "Future fulfillment" do
    subject { Future }

    context "when futurizing a relation" do
      let!(:future) { User.where(name: "").future }

      its(:all) { should have(1).future }

      context "the relation future" do
        specify { future.should_not be_fulfilled }
      end

      context "and executing it" do
        before { future.to_a }

        its(:all) { should have(0).futures }

        context "the future" do
          subject { future }

          it { should be_fulfilled }
        end
      end
    end

    context "when futurizing two relations" do
      let!(:future) { User.where(name: "").future }
      let!(:another_future) { Country.where(name: "").future }

      its(:all) { should have(2).futures }

      context "the first relation future" do
        specify { future.should_not be_fulfilled }
      end

      context "the other relation future" do
        specify { another_future.should_not be_fulfilled }
      end

      context "and executing one of them" do
        before { future.to_a }

        its(:all) { should have(0).futures }

        context "the first relation future" do
          specify { future.should be_fulfilled }
        end

        context "the other relation future" do
          specify { another_future.should be_fulfilled }
        end
      end

      context "and executing another non futurized relation" do
        let!(:normal_relation) { User.where(name: "") }
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