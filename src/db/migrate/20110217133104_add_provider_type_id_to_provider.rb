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

class AddProviderTypeIdToProvider < ActiveRecord::Migration

  PROVIDER_TYPES = { 0 => "Mock", 1 => "Amazon EC2", 2 => "GoGrid", 3 => "Rackspace", 4 => "RHEV-M", 5 => "OpenNebula" }
  INVERTED_PROVIDER_TYPES = PROVIDER_TYPES.invert

  def self.up
    add_column :providers, :provider_type_id, :integer, :null => false, :default => 100
    rename_column :providers, :provider_type, :provider_type_int
    transform_provider_type_column
    remove_column :providers, :provider_type_int
  end

  def self.down
    add_column :providers, :provider_type_temporary, :integer
    transform_provider_type_column_back
    rename_column :providers, :provider_type_temporary, :provider_type
    remove_column :providers, :provider_type_id
  end

  def self.transform_provider_type_column
    Provider.all.each do |provider|
      provider.update_attribute(:provider_type_id, ProviderType.first(:conditions => {:name => PROVIDER_TYPES[provider.provider_type_int]}).id)
    end
  end

  def self.transform_provider_type_column_back
    Provider.all.each do |provider|
      provider.update_attribute(:provider_type_temporary, INVERTED_PROVIDER_TYPES[provider.provider_type.name])
    end
  end
end
