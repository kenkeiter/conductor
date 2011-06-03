# == Schema Information
# Schema version: 20110207110131
#
# Table name: assemblies
#
#  id           :integer         not null, primary key
#  uuid         :string(255)     not null
#  xml          :binary          not null
#  uri          :string(255)
#  name         :string(255)
#  architecture :string(255)
#  summary      :text
#  uploaded     :boolean
#  lock_version :integer         default(0)
#  created_at   :datetime
#  updated_at   :datetime
#

#
# Copyright (C) 2011 Red Hat, Inc.
# Written by Scott Seago <sseago@redhat.com>
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

require 'sunspot_rails'
class LegacyAssembly < ActiveRecord::Base
  include PermissionedObject
  include ImageWarehouseObject
  searchable do
    text :name, :as => :code_substring
    text :architecture, :as => :code_substring
    text :summary, :as => :code_substring
  end

  has_and_belongs_to_many :legacy_templates
  has_and_belongs_to_many :legacy_deployables
  has_and_belongs_to_many :legacy_templates
  has_and_belongs_to_many :deployables
  has_many :instances

  has_many :permissions, :as => :permission_object, :dependent => :destroy,
           :include => [:role],
           :order => "permissions.id ASC"
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  after_create "assign_owner_roles(owner)"

  before_validation :generate_uuid
  before_save :update_xml

  validates_presence_of :uuid
  validates_uniqueness_of :uuid
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of   :name, :maximum => 255
  validates_presence_of :architecture
  validates_presence_of :owner_id

  def self.default_privilege_target_type
    LegacyTemplate
  end

  def update_xml
    xml.name = self.name
    xml.description = self.summary
    xml.architecture = self.architecture
    write_attribute(:xml, xml.to_xml)
  end

  def self.find_or_create(id)
    id ? LegacyAssembly.find(id) : LegacyAssembly.new
  end

end