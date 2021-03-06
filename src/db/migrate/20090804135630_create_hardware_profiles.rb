#
# Copyright (C) 2009 Red Hat, Inc.
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

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class CreateHardwareProfiles < ActiveRecord::Migration
  def self.up
    create_table :hardware_profile_properties do |t|
      t.string  :name, :null => false
      t.string  :kind, :null => false
      t.string  :unit, :null => false
      t.string  :value, :null => false
      t.string  :range_first
      t.string  :range_last
      t.integer :lock_version, :default => 0
      t.timestamps
    end

    create_table :property_enum_entries do |t|
      t.integer :hardware_profile_property_id, :null => false
      t.string :value, :null => false
      t.integer :lock_version, :default => 0
      t.timestamps
    end

    create_table :hardware_profiles do |t|
      t.string  :external_key
      t.string  :name, :null => false, :limit => 1024
      t.integer :memory_id
      t.integer :storage_id
      t.integer :cpu_id
      t.integer :architecture_id
      t.integer :provider_id
      t.integer :lock_version, :default => 0
      t.timestamps
    end

    create_table "hardware_profile_map", :force => true, :id => false do |t|
      t.column "conductor_hardware_profile_id", :integer
      t.column "provider_hardware_profile_id", :integer
    end
  end

  def self.down
    drop_table :hardware_profile_map
    drop_table :hardware_profiles
  end
end
