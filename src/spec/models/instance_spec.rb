require 'spec_helper'

describe Instance do
  before(:each) do
    @instance = Factory.build(:instance)
    @actions = ['start', 'stop']
  end

  it "should require pool to be set" do
    @instance.pool_id = nil
    @instance.should_not be_valid

    @instance.pool_id = 1
    @instance.should be_valid
  end

  it "should require hardware profile to be set" do
    @instance.hardware_profile_id = nil
    @instance.should_not be_valid

    @instance.hardware_profile_id = 1
    @instance.should be_valid
  end

  it "should require image to be set" do
    @instance.image_id = nil
    @instance.should_not be_valid

    @instance.image_id = 1
    @instance.should be_valid
  end

  it "should have a name of reasonable length" do
    [nil, '', 'x'*1025].each do |invalid_name|
      @instance.name = invalid_name
      @instance.should_not be_valid
    end
    @instance.name = 'x'*1024
    @instance.should be_valid

  end

  it "should have unique name" do
    @instance.save!
    second_instance = Factory.build(:instance,
                                    :pool_id => @instance.pool_id,
                                    :name => @instance.name)
    second_instance.should_not be_valid

    second_instance.name = 'unique name'
    second_instance.should be_valid
  end

  it "should be invalid for unknown states" do
    ["new", "pending", "running", "shutting_down", "stopped",
      "create_failed"].each do |valid_state|
      @instance.state = 'invalid_state'
      @instance.should_not be_valid
      @instance.state = valid_state
      @instance.should be_valid
    end
  end


  it "should tell apart valid and invalid actions" do
    @instance.stub!(:get_action_list).and_return(@actions)
    @instance.valid_action?('invalid action').should == false
    @instance.valid_action?('start').should == true
  end

  it "should return action list" do
    @instance.get_action_list.should eql([])

    InstanceTask.stub!(:valid_actions_for_instance_state).and_return(
        @actions)
    @instance.get_action_list.should eql(@actions)
  end

  it "should be able to queue new actions" do
    @instance.stub!(:get_action_list).and_return(@actions)
    user = User.new

    invalid_task = @instance.queue_action(user, 'unknown action')
    invalid_task.should == false
    valid_task = @instance.queue_action(user, 'stop')
    valid_task.should_not == false
  end

  it "should be able to query and set up frontend realm" do
    provider = Factory.build(:mock_provider2)
    provider.stub!(:connect).and_return(mock('DeltaCloud'))
    provider.save!
    cloud_account = CloudAccount.new(:provider_id => provider.id,
                                     :username => 'john doe',
                                     :password => 'asdf')
    cloud_account.save!
    @instance = Factory.create(:instance,
                               :cloud_account_id => cloud_account.id)
    @instance.front_end_realm.should eql('mock2:john doe')

    realm = Factory.create(:realm, :name => 'a realm',
                           :provider_id => provider.id)
    @instance.realm = realm
    @instance.front_end_realm.should eql('mock2:john doe/a realm')

    Factory.create(:realm, :name => 'different realm',
                   :provider_id => provider.id)
    @instance.front_end_realm = 'mock2:john doe/different realm'
    @instance.front_end_realm.should eql('mock2:john doe/different realm')
  end


end