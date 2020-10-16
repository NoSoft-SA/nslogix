
require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    add_column :cultivar_groups,:active, TrueClass, default: true
    add_column :cultivars,:active, TrueClass, default: true
    add_column :marketing_varieties,:active, TrueClass, default: true
    add_column :std_fruit_size_counts,:active, TrueClass, default: true
    add_column :fruit_actual_counts_for_packs,:active, TrueClass, default: true
    add_column :fruit_size_references,:active, TrueClass, default: true
    add_column :pallet_formats,:active, TrueClass, default: true
    add_column :basic_pack_codes,:active, TrueClass, default: true
    add_column :standard_pack_codes,:active, TrueClass, default: true
    add_column :uom_types,:active, TrueClass, default: true
    add_column :uoms,:active, TrueClass, default: true
  end

  down do
    drop_column :cultivar_groups, :active
    drop_column :cultivars, :active
    drop_column :marketing_varieties, :active
    drop_column :std_fruit_size_counts, :active
    drop_column :fruit_actual_counts_for_packs, :active
    drop_column :fruit_size_references, :active
    drop_column :pallet_formats, :active
    drop_column :basic_pack_codes, :active
    drop_column :standard_pack_codes, :active
    drop_column :uom_types, :active
    drop_column :uoms, :active
  end
end
