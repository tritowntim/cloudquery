class ApplicationController < ActionController::Base
  protect_from_forgery

  def default_db
    params['db_name'] = Rails.configuration.database_configuration['query_db']['database'] unless params['db_name']
  end

  def list_db
    @db_list = Metadata.all_databases
  end
end
