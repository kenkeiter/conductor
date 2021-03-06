#
# Copyright (C) 2011 Red Hat, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA  02110-1301, USA.  A copy of the GNU General Public License is
# also available at http://www.gnu.org/copyleft/gpl.html.

require 'spec_helper'

describe PoolFamily do

  before(:each) do
    @pool = FactoryGirl.create :pool
    @pool_family = @pool.pool_family
    @provider_account = Factory.build :mock_provider_account
    @provider_account.pool_families << @pool_family
    @provider_account.save!
  end

  it "should validate default pool family" do
    @pool_family.should be_valid
  end

  it "should require a valid name" do
    [nil, ""].each do |invalid_value|
      @pool_family.name = invalid_value
      @pool_family.should_not be_valid
    end
  end

  it "should have pool" do
    @pool_family.pools.size.should == 2 #default pool + pool created here
    @pool.pool_family.id.should == @pool_family.id
  end

  it "should have account" do
    @pool_family.provider_accounts.size.should == 1
    @pool_family.provider_accounts[0].id.should == @provider_account.id
  end

  it "should not be valid if name is too long" do
    @pool_family.name = ('a' * 256)
    @pool_family.valid?.should be_false
    @pool_family.errors[:name].should_not be_nil
    @pool_family.errors[:name][0].should =~ /^is too long.*/
  end

  it "should not be valid if name contains special characters" do
    @pool_family.name = '.'
    @pool_family.valid?.should be_false
    @pool_family.errors[:name].should_not be_nil
    @pool_family.errors[:name][0].should =~ /^must only contain.*/
  end

  it "should require quota to be set" do
    @pool_family.should be_valid

    @pool_family.quota = nil
    @pool_family.should_not be_valid
  end
end
