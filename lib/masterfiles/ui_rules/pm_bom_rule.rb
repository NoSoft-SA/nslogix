# frozen_string_literal: true

module UiRules
  class PmBomRule < Base
    def generate_rules
      @repo = MasterfilesApp::BomsRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode

      form_name 'pm_bom'
    end

    def set_show_fields
      fields[:bom_code] = { renderer: :label }
      fields[:erp_bom_code] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
        bom_code: { required: true },
        erp_bom_code: {},
        description: {}
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_pm_bom(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(bom_code: nil,
                                    erp_bom_code: nil,
                                    description: nil)
    end
  end
end
