# frozen_string_literal: true

module UiRules
  class PmProductRule < Base
    def generate_rules
      @repo = MasterfilesApp::BomsRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode

      form_name 'pm_product'
    end

    def set_show_fields
      pm_subtype_id_label = @repo.find_hash(:pm_subtypes, @form_object.pm_subtype_id)[:subtype_code]
      fields[:pm_subtype_id] = { renderer: :label, with_value: pm_subtype_id_label, caption: 'Pm Subtype' }
      fields[:erp_code] = { renderer: :label }
      fields[:product_code] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
        pm_subtype_id: { renderer: :select,
                         options: @repo.for_select_pm_subtypes,
                         disabled_options: @repo.for_select_inactive_pm_subtypes,
                         caption: 'pm_subtype',
                         required: true },
        erp_code: { required: true },
        product_code: { required: true },
        description: {}
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_pm_product(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(pm_subtype_id: nil,
                                    erp_code: nil,
                                    product_code: nil,
                                    description: nil)
    end
  end
end
