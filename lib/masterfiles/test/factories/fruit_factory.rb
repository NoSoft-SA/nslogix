# frozen_string_literal: true

module MasterfilesApp
  module FruitFactory # rubocop:disable Metrics/ModuleLength
    def create_grade(opts = {})
      default = {
        grade_code: Faker::Lorem.unique.word,
        description: Faker::Lorem.word,
        active: true
      }
      DB[:grades].insert(default.merge(opts))
    end

    def create_treatment_type(opts = {})
      default = {
        treatment_type_code: Faker::Lorem.unique.word,
        description: Faker::Lorem.word,
        active: true
      }
      DB[:treatment_types].insert(default.merge(opts))
    end

    def create_treatment(opts = {})
      treatment_type_id = create_treatment_type

      default = {
        treatment_type_id: treatment_type_id,
        treatment_code: Faker::Lorem.unique.word,
        description: Faker::Lorem.word,
        active: true
      }
      DB[:treatments].insert(default.merge(opts))
    end

    def create_inventory_code(opts = {})
      default = {
        inventory_code: Faker::Lorem.unique.word,
        description: Faker::Lorem.word,
        active: true
      }
      DB[:inventory_codes].insert(default.merge(opts))
    end

    def create_basic_pack(opts = {})
      default = {
        basic_pack_code: Faker::Lorem.unique.word,
        description: Faker::Lorem.word,
        length_mm: Faker::Number.number(digits: 4),
        width_mm: Faker::Number.number(digits: 4),
        height_mm: Faker::Number.number(digits: 4),
        active: true
      }
      DB[:basic_packs].insert(default.merge(opts))
    end

    def create_standard_pack(opts = {})
      basic_pack_id = create_basic_pack
      default = {
        standard_pack_code: Faker::Lorem.unique.word,
        description: Faker::Lorem.word,
        standard_pack_label: Faker::Lorem.word,
        active: true,
        material_mass: Faker::Number.decimal,
        basic_pack_id: basic_pack_id,
        use_size_ref_for_edi: false
      }
      DB[:standard_packs].insert(default.merge(opts))
    end

    def create_standard_count(opts = {})
      commodity_id = create_commodity
      uom_id = create_uom

      default = {
        commodity_id: commodity_id,
        uom_id: uom_id,
        size_count_description: Faker::Lorem.word,
        marketing_size_range_mm: Faker::Lorem.word,
        marketing_weight_range: Faker::Lorem.word,
        size_count_interval_group: Faker::Lorem.word,
        size_count_value: Faker::Number.number(digits: 4),
        minimum_size_mm: Faker::Number.number(digits: 4),
        maximum_size_mm: Faker::Number.number(digits: 4),
        average_size_mm: Faker::Number.number(digits: 4),
        minimum_weight_gm: 1.0,
        maximum_weight_gm: 1.0,
        average_weight_gm: 1.0,
        active: true
      }
      DB[:standard_counts].insert(default.merge(opts))
    end

    def create_actual_count(opts = {})
      standard_count_id = create_standard_count
      basic_pack_id = create_basic_pack
      standard_pack_ids = create_standard_pack
      size_reference_ids = create_size_reference

      default = {
        standard_count_id: standard_count_id,
        basic_pack_id: basic_pack_id,
        actual_count_value: Faker::Number.number(digits: 4),
        standard_pack_ids: "{#{standard_pack_ids}}",
        size_reference_ids: "{#{size_reference_ids}}",
        active: true
      }
      DB[:actual_counts].insert(default.merge(opts))
    end

    def create_size_reference(opts = {})
      default = {
        size_reference: Faker::Lorem.unique.word,
        edi_out_code: Faker::Lorem.word,
        active: true,
        created_at: '2010-01-01 12:00',
        updated_at: '2010-01-01 12:00'
      }
      DB[:size_references].insert(default.merge(opts))
    end
  end
end
