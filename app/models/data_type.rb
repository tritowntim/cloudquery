class DataType < ActiveRecord::Base

  def self.load_all
    @all_data_types = Hash[DataType.all.map { |data_type| [self.format_key(data_type.ftype, data_type.fmod), data_type.description] }]
  end

  def self.lookup(ftype, fmod)
    key = self.format_key(ftype, fmod)
    data_type = @all_data_types[key]
    unless data_type
      description = connection.execute("SELECT format_type(#{ftype}, #{fmod})").getvalue(0,0)
      DataType.create ftype: ftype, fmod: fmod, description: description
      @all_data_types[key] = description
    else
      data_type
    end
  end

  def self.format_key(ftype, fmod)
    "#{ftype},#{fmod}"
  end

end
