# frozen_string_literal: true

module UiRules
  class CultivarRule < Base
    def generate_rules
      @repo = MasterfilesApp::CultivarRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'cultivar'
    end

    def set_show_fields  # rubocop:disable Metrics/AbcSize
      commodity_id_label = MasterfilesApp::CommodityRepo.new.find_commodity(@form_object.commodity_id)&.code
      fields[:commodity_id] = { renderer: :label, with_value: commodity_id_label }
      fields[:cultivar_group_id] = { renderer: :label, with_value: @form_object.cultivar_group_code }
      fields[:cultivar_name] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
      fields[:marketing_varieties] = { renderer: :list, items: cultivar_marketing_varieties }
      fields[:cultivar_code] = { renderer: :label }
    end

    def common_fields
      {
        commodity_id: { renderer: :select, options: MasterfilesApp::CommodityRepo.new.for_select_commodities },
        cultivar_group_id: { renderer: :select,
                             options: @repo.for_select_cultivar_groups,
                             disabled_options: @repo.for_select_inactive_cultivar_groups,
                             prompt: 'Select Cultivar Group' },
        cultivar_name: { required: true },
        cultivar_code: {},
        description: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_cultivar(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(commodity_id: nil,
                                    cultivar_group_id: nil,
                                    cultivar_name: nil,
                                    description: nil,
                                    cultivar_code: nil)
    end

    def cultivar_marketing_varieties
      @repo.find_cultivar_marketing_varieties(@options[:id])
    end
  end
end
