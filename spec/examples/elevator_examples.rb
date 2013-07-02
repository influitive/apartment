require 'spec_helper'

shared_examples_for "an apartment elevator" do

  context "single request" do
    it "should switch the db" do
      ActiveRecord::Base.connection.schema_search_path.should_not == %{"#{database1}"}

      visit(domain1)
      ActiveRecord::Base.connection.schema_search_path.should == %{"#{database1}"}
    end
  end

  context "simultaneous requests" do

    let!(:c1_user_count) { api.process(database1){ (2 + rand(2)).times{ User.create } } }
    let!(:c2_user_count) { api.process(database2){ (c1_user_count + 2).times{ User.create } } }

    it "should fetch the correct user count for each session based on the elevator processor" do
      visit(domain1)

      in_new_session do |session|
        session.visit(domain2)
        User.count.should == c2_user_count
      end

      visit(domain1)
      User.count.should == c1_user_count
    end
  end
end
