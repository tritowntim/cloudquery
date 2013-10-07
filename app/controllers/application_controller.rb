class ApplicationController < ActionController::Base
  protect_from_forgery

  def default_db
    @db_name = if params['db_name']
      params['db_name']
    else
      Rails.configuration.database_configuration['query_db']['database']
    end
  end

  def list_db
    @db_list = Metadata.all_databases
  end
end
