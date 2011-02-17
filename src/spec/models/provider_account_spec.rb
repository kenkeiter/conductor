require 'spec_helper'

describe ProviderAccount do
  fixtures :all
  before(:each) do
    @provider_account = Factory :mock_provider_account
  end

  it "should not be destroyable if it has instances" do
    @provider_account.instances << Instance.new
    @provider_account.destroyable?.should be_false
    @provider_account.destroy.should be_false

    @provider_account.instances.clear
    @provider_account.destroyable?.should be_true
    @provider_account.destroy.equal?(@provider_account).should be_true
    @provider_account.should be_frozen
  end

  it "should check the validitiy of the cloud account login credentials" do
    mock_provider = Factory :mock_provider

    invalid_provider_account = Factory.build(:provider_account, :username => "wrong_username", :password => "wrong_password", :provider => mock_provider)
    invalid_provider_account.should_not be_valid

    valid_provider_account = Factory.build(:mock_provider_account, :provider => mock_provider)
    valid_provider_account.should be_valid
  end

  it "should fail to create a cloud account if the provider credentials are invalid" do
    provider_account = Factory.build(:mock_provider_account, :password => "wrong_password")
    provider_account.save.should == false
  end

  it "should create an instance_key if provider is EC2" do
    @client = mock('DeltaCloud', :null_object => true)
    @provider = Factory.build :ec2_provider
    @key = mock('Key', :null_object => true)
    @key.stub!(:pem).and_return("PEM")
    @key.stub!(:id).and_return("1_user")
    @client.stub!(:"feature?").and_return(true)
    @client.stub!(:"create_key").and_return(@key)

    provider_account = Factory.build :ec2_provider_account
    provider_account.stub!(:connect).and_return(@client)
    provider_account.stub!(:generate_auth_key).and_return(@key)
    provider_account.save
    provider_account.instance_key.should_not == nil
    provider_account.instance_key.pem == "PEM"
    provider_account.instance_key.id == "1_user"
  end

  it "when calling connect and it fails with exception it will return nil" do
    DeltaCloud.should_receive(:new).and_raise(Exception.new)

    @provider_account.connect.should be_nil
  end

  it "should generate credentials xml" do
    expected_xml = <<EOT
<?xml version="1.0"?>
<provider_credentials>
  <ec2_credentials>
    <account_number>1234</account_number>
    <access_key>user</access_key>
    <secret_access_key>pass</secret_access_key>
    <certificate>cert</certificate>
    <key>priv_key</key>
  </ec2_credentials>
</provider_credentials>
EOT
    provider_account = Factory.build(:mock_provider_account,
                                  :username => 'user',
                                  :password => 'pass',
                                  :account_number => '1234',
                                  :x509_cert_priv => 'priv_key',
                                  :x509_cert_pub => 'cert'
                                 )
    provider_account.build_credentials.should eql(expected_xml)
  end
end