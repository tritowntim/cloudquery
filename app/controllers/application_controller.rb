class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :all_databases

  private

  def all_databases
    @databases = Database.refresh_from_config
  end
end
