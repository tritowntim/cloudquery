class DatabasesController < ApplicationController

  def index
    @databases = Database.refresh_from_config
  end

  def show
    @database = Database.find(params[:id])
  end
end
