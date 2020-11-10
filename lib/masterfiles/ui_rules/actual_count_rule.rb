# frozen_string_literal: true

module UiRules
  class ActualCountsRule < Base
    def generate_rules
      @repo = MasterfilesApp::FruitSizeRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'actual_count'
    end

    def set_show_fields # rubocop:disable Metrics/AbcSize
      standard_count_id_label = @repo.find_hash(:standard_counts, @form_object.standard_count_id)[:size_count_value]
      basic_pack_id_label = @repo.find_hash(:basic_packs, @form_object.basic_pack_id)[:basic_pack_code]
      fields[:standard_count_id] = { renderer: :label, with_value: standard_count_id_label, caption: 'Standard Count' }
      fields[:basic_pack_id] = { renderer: :label, with_value: basic_pack_id_label, caption: 'Basic Pack Code' }
      fields[:actual_count_value] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
      fields[:standard_packs] = { renderer: :list, items: standard_packs, caption: 'Standard Packs' }
      fields[:size_references] = { renderer: :list, items: size_references }
    end

    def common_fields
      {
        standard_count_id: { renderer: :select,
                             options: @repo.for_select_standard_counts,
                             disabled_options: @repo.for_select_inactive_standard_counts,
                             caption: 'Standard Count',
                             required: true },
        basic_pack_id: { renderer: :select,
                         options: @repo.for_select_basic_packs,
                         disabled_options: @repo.for_select_inactive_basic_packs,
                         caption: 'Basic Pack Code',
                         required: true },
        actual_count_value: { required: true },
        standard_pack_ids: { renderer: :multi,
                             options: MasterfilesApp::FruitSizeRepo.new.for_select_standard_packs,
                             selected: @form_object.standard_pack_ids,
                             caption: 'Standard Pack Codes',
                             required: true },
        size_reference_ids: { renderer: :multi,
                              options: MasterfilesApp::FruitSizeRepo.new.for_select_size_references,
                              selected: @form_object.size_reference_ids,
                              caption: 'Size References',
                              required: true }
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_actual_count(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(standard_count_id: nil,
                                    basic_pack_id: nil,
                                    actual_count_value: nil,
                                    standard_pack_ids: [],
                                    size_reference_ids: [])
    end

    def standard_packs
      @repo.standard_packs(@options[:id])
    end

    def size_references
      @repo.size_references(@options[:id])
    end
  end
end
