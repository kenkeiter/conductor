#Seed the DB with fixture data

# We can't stub out these methods properly in cucumber, and we don't want to
# couple these tests to require the core server be running (connections should be tested
# in the client code), so override the methods for tests here.
Provider.class_eval do
  def valid_framework?
    true
  end
end

ProviderAccount.class_eval do

  def valid_credentials?
    credentials_hash['username'].to_s == 'mockuser' && credentials_hash['password'].to_s == 'mockpassword'
  end

#  def instance_key
#    @key = mock('Key').as_null_object
#    @key.stub!(:pem).and_return("PEM")
#    @key.stub!(:id).and_return("1_user")
#    @key
#  end
end

Deployment.class_eval do
  def condormatic_instance_create(task)
    true
  end
end

InstanceKey.class_eval do
  def replace_on_server(addr, new)
    true
  end
end

# for cucumber tests we want to authenticate against local db,
# not LDAP
User.class_eval do
  class << self
    alias authenticate_using_ldap authenticate
  end
end
