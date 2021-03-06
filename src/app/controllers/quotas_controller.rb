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

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.


class QuotasController < ApplicationController
  before_filter :require_user

  def show
    @parent = get_parent_object(params)
    @parent_type = params[:parent_type]
    @quota = @parent.quota

    require_privilege(Privilege::VIEW, Quota, @parent)
  end

  def edit
    @parent = get_parent_object(params)
    @parent_type = params[:parent_type]
    @name = get_parent_name(@parent, @parent_type)

    @quota = @parent.quota

    require_privilege(Privilege::MODIFY, Quota, @parent)
  end

  def update
    @parent = @parent = get_parent_object(params)
    @parent_type = params[:parent_type]
    require_privilege(Privilege::MODIFY, Quota, @parent)

    @quota = @parent.quota
    @name = get_parent_name(@parent, @parent_type)
    if @quota.update_attributes(params[:quota])
      flash[:notice] = "Quota updated!"
      redirect_to :action => 'show', :id => @parent, :parent_type => @parent_type
    else
      flash[:warning] = "Could not update quota, please check you have entered valid values"
      render :action => "edit"
    end
  end

  def reset
    @parent = @parent = get_parent_object(params)
    @parent_type = params[:parent_type]
    require_privilege(Privilege::MODIFY, Quota, @parent)

    @quota = @parent.quota
    @quota.maximum_running_instances = Quota::NO_LIMIT
    @quota.maximum_total_instances = Quota::NO_LIMIT

    if @quota.save!
      flash[:notice] = "Quota updated!"
    end
      redirect_to :action => 'show', :id => @parent, :parent_type => @parent_type
  end

  private
  def get_parent_object(params)
    if params[:parent_type] == "pool"
      return Pool.find(params[:id])
    elsif params[:parent_type] == "cloud_account"
      return ProviderAccount.find(params[:id])
    end
    #TODO Throw no match to pool or cloud account exception
  end

  def get_parent_name(parent, parent_type)
    if parent_type == "pool"
      return parent.name
    elsif parent_type == "cloud_account"
      return parent.username
    end
    #TODO Throw no match to pool or cloud account exception
  end

  def check_params_infinite_limits(params)
    params.each_pair do |key, value|
      if value == ""
        params[key] = Quota::NO_LIMIT
      end
    end
    return params
  end


end
