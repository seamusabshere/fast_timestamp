# Expects a ::Timestamp ActiveRecord class with timestampable_type, timestampable_id, key:string, and stamped_at:datetime.
module FastTimestamp
  def self.included(base)
    base.class_eval { after_destroy :fast_destroy_timestamps }
  end
  
  def timestamp!(key)
    raise "Can't timestamp new records" if new_record?
    transaction do
      t = ::Timestamp.find_or_create_by_timestampable_type_and_timestampable_id_and_key(self.class.base_class.name, id, key.to_s)
      t.update_attribute :stamped_at, Time.zone.now
    end
  end
  
  def untimestamp!(key)
    if t = ::Timestamp.find_by_timestampable_type_and_timestampable_id_and_key(self.class.base_class.name, id, key.to_s)
      t.destroy
    end
  end

  def timestamped?(key)
    raise "Can't check timestamps on new record" if new_record?
    ::Timestamp.exists? :timestampable_type => self.class.base_class.name, :timestampable_id => id, :key => key.to_s
  end

  # returns a Time object
  def timestamp_for(key)
    if t = ::Timestamp.find_by_timestampable_type_and_timestampable_id_and_key(self.class.base_class.name, id, key.to_s)
      t.read_attribute :stamped_at
    end
  end

  def fast_destroy_timestamps
    ::Timestamp.destroy_all :timestampable_type => self.class.base_class.name, :timestampable_id => id
    true
  end
end
