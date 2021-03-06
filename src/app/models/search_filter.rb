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

module SearchFilter
  def self.included(base)
    base.class_eval do
      scope :search_filter, lambda {|str, cols|
        if str.to_s.empty?
          {:conditions => {}}
        else
          {:conditions => [cols.map {|c| "#{c} like ?"}.join(" OR ")] + Array.new(cols.size, "%#{str}%")}
        end
      }
    end
  end
end
