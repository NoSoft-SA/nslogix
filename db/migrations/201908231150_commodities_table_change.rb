# require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    add_column :commodities, :requires_standard_counts, TrueClass, default: true
  end

  down do
    drop_column :commodities, :requires_standard_counts
  end
end
