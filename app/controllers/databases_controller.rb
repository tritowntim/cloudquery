class DatabasesController < ApplicationController
  before_action :all

  def index
  end

  def show
    @database = Database.find(params[:id])
  end

  private
  def all
    @databases = Database.refresh_from_config
  end

end
