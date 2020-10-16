require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    create_table(:uom_types, ignore_index_errors: true) do
      primary_key :id
      String :code, null: false

      index [:code], name: :uom_types_unique_code, unique: true
    end

    create_table(:uoms, ignore_index_errors: true) do
      primary_key :id
      foreign_key :uom_type_id, :uom_types, null: false, key: [:id]
      String :uom_code, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:uom_code, :uom_type_id], name: :fki_uom_codes_uom_types, unique: true
    end
    pgt_created_at(:uoms,
                   :created_at,
                   function_name: :uoms_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:uoms,
                   :updated_at,
                   function_name: :uoms_set_updated_at,
                   trigger_name: :set_updated_at)

    # As an example for referring to this table:
    # create_table(:mr_uoms, ignore_index_errors: true) do
    #   primary_key :id
    #   foreign_key :uom_id, :uoms, null: false, key: [:id]
    #   foreign_key :mr_sub_type_id, :material_resource_sub_types, key: [:id]
    #   foreign_key :mr_product_variant_id, :material_resource_product_variants, key: [:id]
    #
    #   index [:mr_sub_type_id, :uom_id], name: :fki_mr_sub_types_uoms, unique: true
    #   index [:mr_product_variant_id, :uom_id], name: :fki_mr_product_variants_uoms, unique: true
    # end
  end

  down do
    drop_trigger(:uoms, :set_created_at)
    drop_function(:uoms_set_created_at)
    drop_trigger(:uoms, :set_updated_at)
    drop_function(:uoms_set_updated_at)
    drop_table(:uoms)

    drop_table(:uom_types)
  end
end
