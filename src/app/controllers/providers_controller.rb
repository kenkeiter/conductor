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

class ProvidersController < ApplicationController
  before_filter :require_user
  before_filter :load_providers, :only => [:index, :show, :new, :edit, :create, :update]

  def index
    @params = params
    @provider = @providers.first

    respond_to do |format|
      format.html do
        if @providers.present?
          redirect_to edit_provider_path(@provider)
        else
          render :action => :index
        end
      end
      format.xml { render :partial => 'list.xml' }
    end
  end

  def new
    require_privilege(Privilege::CREATE, Provider)
    @provider = Provider.new
    @provider.url = Provider::DEFAULT_DELTACLOUD_URL
  end

  def edit
    @provider = Provider.find_by_id(params[:id])
    require_privilege(Privilege::MODIFY, @provider)

    @alerts = provider_alerts(@provider)

    if params.delete :test_provider
      test_connection(@provider)
    end

    load_provider_tabs

    respond_to do |format|
      format.html
      format.js { render :partial => @view }
      format.json { render :json => @provider }
    end

  end

  def show
    @provider = Provider.find(params[:id])
    @hardware_profiles = @provider.hardware_profiles
    @realm_names = @provider.realms.collect { |r| r.name }

    require_privilege(Privilege::VIEW, @provider)
    @tab_captions = ['Properties', 'HW Profiles', 'Realms', 'Provider Accounts', 'Services', 'History', 'Permissions']
    @details_tab = params[:details_tab].blank? ? 'properties' : params[:details_tab]

    if params.delete :test_provider
      test_connection(@provider)
    end

    respond_to do |format|
      format.html { render :action => 'show' }
      format.js do
        if params.delete :details_pane
          render :partial => 'layouts/details_pane' and return
        end
        render :partial => @details_tab and return
      end
    end
  end

  def create
    require_privilege(Privilege::CREATE, Provider)
    if params[:provider].has_key?(:provider_type_deltacloud_driver)
      provider_type = params[:provider].delete(:provider_type_deltacloud_driver)
      provider_type = ProviderType.find_by_deltacloud_driver(provider_type)
      params[:provider][:provider_type_id] = provider_type.id
    end
    @provider = Provider.new(params[:provider])
    if !@provider.connect
      flash[:warning] = "Failed to connect to Provider"
      render :action => "new"
    else
      if @provider.save
        @provider.assign_owner_roles(current_user)
        flash[:notice] = "Provider added."
        redirect_to edit_provider_path(@provider)
      else
        flash[:warning] = "Cannot add the provider."
        render :action => "new"
      end
    end
  end

  def update
    @provider = Provider.find_by_id(params[:id])
    require_privilege(Privilege::MODIFY, @provider)
    @provider.update_attributes(params[:provider])
    if !@provider.connect
      flash.now[:warning] = "Failed to connect to Provider"
      load_provider_tabs
      render :action => "edit"
    else
      if @provider.errors.empty? and @provider.save
        flash[:notice] = "Provider updated."
        redirect_to edit_provider_path(@provider)
      else
        flash[:warning] = "Cannot update the provider."
        load_provider_tabs
        render :action => 'edit'
      end
    end
  end

  def destroy
    provider = Provider.find(params[:id])
    require_privilege(Privilege::MODIFY, provider)
    provider.destroy

    respond_to do |format|
      format.html { redirect_to providers_path }
    end
  end

  def test_connection(provider)
    @provider.errors.clear
    if @provider.connect
      flash.now[:notice] = "Successfully Connected to Provider"
    else
      flash.now[:warning] = "Failed to Connect to Provider"
      @provider.errors.add :url
    end
  end

  protected
  def load_providers
    @providers = Provider.list_for_user(current_user, Privilege::VIEW, :order => :name)
  end

  def provider_alerts(provider)
    alerts = []

    # Quota Alerts
    provider.provider_accounts.each do |provider_account|
      unless provider_account.quota.maximum_running_instances == nil
        if provider_account.quota.maximum_running_instances < provider_account.quota.running_instances
          alerts << {
            :type => "critical",
            :subject => "Quota",
            :alert_type => "Account Quota Exceeded",
            :path => edit_provider_provider_account_path(@provider,provider_account),
            :description => "Quota limit of running instances for #{provider_account.name} account has been exceeded."
          }
        end

        if (70..100) === provider_account.quota.percentage_used.round
          alerts << {
            :type => "warning",
            :subject => "Quota",
            :alert_type => "#{provider_account.quota.percentage_used.round}% Account Quota Reached",
            :path => provider_provider_account_path(@provider,provider_account),
            :description => "#{provider_account.quota.percentage_used.round}% of Quota limit for running instances for #{provider_account.name} account has been reached."
          }
        end
      end
    end

    return alerts
  end

  def load_provider_tabs
    @view = filter_view? ? 'provider_accounts/list' : 'edit' unless params[:details_tab]
    if params[:details_tab] == 'connectivity'
      @view = filter_view? ? 'provider_accounts/list' : 'edit'
    elsif params[:details_tab] == 'realms'
      @view = filter_view? ? 'realms/list' : 'realms/list'
    elsif params[:details_tab] == 'hardware_profiles'
      @view = filter_view? ? 'hardware_profiles/list' : 'hardware_profiles/list'
    #elsif params[:details_tab] == 'roles'
    #  @view = filter_view? ? 'permissions/list' : 'permissions/list'
    end
    #TODO add links to real data for history,properties,permissions
    @tabs = [{:name => 'Connectivity', :view => @view, :id => 'connectivity', :count => @provider.provider_accounts.count},
             {:name => 'Realms', :view => @view, :id => 'realms', :count => @provider.frontend_realms.count},
             {:name => 'Hardware', :view => @view, :id => 'hardware_profiles', :count => @provider.hardware_profiles.count},
             #{:name => 'Roles & Permissions', :view => @view, :id => 'roles', :count => @provider.permissions.count},
    ]
    details_tab_name = params[:details_tab].blank? ? 'connectivity' : params[:details_tab]
    @details_tab = @tabs.find {|t| t[:id] == details_tab_name} || @tabs.first[:name].downcase

    @provider_accounts = @provider.provider_accounts if @details_tab[:id] == 'connectivity'
    #@realms = @provider.realms if @details_tab[:id] == 'realms'
    @realms = @provider.frontend_realms if @details_tab[:id] == 'realms'
    @hardware_profiles = @provider.hardware_profiles if @details_tab[:id] == 'hardware_profiles'
    #@permissions = @provider.permissions if @details_tab[:id] == 'roles'

    @view = @details_tab[:view]
  end
end
