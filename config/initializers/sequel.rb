Sequel.default_timezone = :utc

# Make all subclasses active_model compliant (called before loading subclasses)
Sequel::Model.plugin :active_model
Sequel::Model.plugin :timestamps, :update_on_create=>true
Sequel::Model.plugin :touch

# Make the Album class active_model compliant
# Query.plugin :active_model
# Timestamp Album instances, with custom column names
# Query.plugin :timestamps, :update_on_create=>true
DB = Sequel.postgres(YAML.load_file('config/database.yml')["#{ENV['RAILS_ENV']}_sequel"])

QUERY_DB = Sequel.postgres(YAML.load_file('config/database.yml')['query_db_sequel'])