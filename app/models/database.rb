class Database < ActiveRecord::Base

  def self.refresh_from_config
    databases = Database.all
    database_names = databases.map { |database| database.name }
    database_names.concat %w{defaults test query_db}
    save_new_databases(databases, database_names)
    databases
  end

  def self.save_new_databases(databases, database_names)
    Rails.configuration.database_configuration.keys.each do |key|
      unless database_names.include?(key)
        databases << Database.create(name: key)
      end
    end
  end

end
