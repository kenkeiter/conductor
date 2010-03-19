require 'spec_helper'

describe HardwareProfilesController do

  before(:each) do
    @admin_permission = Factory :admin_permission
    @admin = @admin_permission.user
    activate_authlogic
  end

  it "should provide ui to view all hardware profiles" do
     UserSession.create(@admin)
     get :index
     response.should be_success
     assigns[:hardware_profiles].size.should == HardwareProfile.count
     response.should render_template("index")
  end

end