require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:address_types, ignore_index_errors: true) do
      primary_key :id
      String :address_type, size: 255, null:false
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:address_type], name: :addresses_types_unique_code, unique: true
    end
    pgt_created_at(:address_types,
                   :created_at,
                   function_name: :pgt_address_types_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:address_types,
                   :updated_at,
                   function_name: :pgt_address_types_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:addresses, ignore_index_errors: true) do
      primary_key :id
      foreign_key :address_type_id, :address_types, type: :integer, null: false
      String :address_line_1, size: 255, null:false
      String :address_line_2, size: 255
      String :address_line_3, size: 255
      String :city, size: 255
      String :postal_code, size: 255
      String :country, size: 255
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:address_type_id], name: :fki_addresses_address_type_id
    end
    pgt_created_at(:addresses,
                   :created_at,
                   function_name: :pgt_addresses_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:addresses,
                   :updated_at,
                   function_name: :pgt_addresses_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:party_addresses, ignore_index_errors: true) do
      primary_key :id
      foreign_key :address_id, :addresses, type: :integer, null: false
      foreign_key :party_id, :parties, type: :integer, null: false
      foreign_key :address_type_id, :address_types, type: :integer, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:address_id], name: :fki_party_addresses_address_id
      index [:party_id], name: :fki_party_addresses_party_id
      index [:party_id, :address_type_id], name: :party_address_type_unique_code, unique: true
    end
    pgt_created_at(:party_addresses,
                   :created_at,
                   function_name: :pgt_party_addresses_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:party_addresses,
                   :updated_at,
                   function_name: :pgt_party_addresses_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:party_addresses, :set_created_at)
    drop_function(:pgt_party_addresses_set_created_at)
    drop_trigger(:party_addresses, :set_updated_at)
    drop_function(:pgt_party_addresses_set_updated_at)
    drop_table(:party_addresses)

    drop_trigger(:addresses, :set_created_at)
    drop_function(:pgt_addresses_set_created_at)
    drop_trigger(:addresses, :set_updated_at)
    drop_function(:pgt_addresses_set_updated_at)
    drop_table(:addresses)

    drop_trigger(:address_types, :set_created_at)
    drop_function(:pgt_address_types_set_created_at)
    drop_trigger(:address_types, :set_updated_at)
    drop_function(:pgt_address_types_set_updated_at)
    drop_table(:address_types)
  end
end
