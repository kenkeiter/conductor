# == Schema Information
# Schema version: 20110207110131
#
# Table name: instance_events
#
#  id          :integer         not null, primary key
#  instance_id :integer         not null
#  event_type  :string(255)     not null
#  event_time  :datetime
#  status      :string(255)
#  message     :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

# Copyright (C) 2010 Red Hat, Inc.
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

class Event < ActiveRecord::Base
  belongs_to :source, :polymorphic => true

  validates_presence_of :source_id
  validates_presence_of :source_type
end