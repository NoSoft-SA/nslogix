# frozen_string_literal: true

module MasterfilesApp
  class UomRepo < BaseRepo
    build_for_select :uom_types,
                     label: :uom_type_code,
                     value: :id,
                     order_by: :uom_type_code
    build_inactive_select :uom_types,
                          label: :uom_type_code,
                          value: :id,
                          order_by: :uom_type_code

    build_for_select :uoms,
                     label: :uom_code,
                     value: :id,
                     order_by: :uom_code
    build_inactive_select :uoms,
                          label: :uom_code,
                          value: :id,
                          order_by: :uom_code

    crud_calls_for :uom_types, name: :uom_type, wrapper: UomType
    crud_calls_for :uoms, name: :uom, wrapper: Uom

    def find_uom(id)
      find_with_association(:uoms, id,
                            parent_tables: [{ parent_table: :uom_types, flatten_columns: { uom_type_code: :uom_type_code } }],
                            wrapper: MasterfilesApp::Uom)
    end

    def default_uom_type_id
      get_id(:uom_types, uom_type_code: AppConst::UOM_TYPE)
    end
  end
end
