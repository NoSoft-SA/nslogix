# frozen_string_literal: true

module UiRules
  class PmTypeRule < Base
    def generate_rules
      @repo = MasterfilesApp::BomsRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode

      form_name 'pm_type'
    end

    def set_show_fields
      fields[:pm_type_code] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
      fields[:pm_subtypes] = { renderer: :list, items: pm_subtypes }
    end

    def common_fields
      {
        pm_type_code: { required: true },
        description: { required: true }
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_pm_type(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(pm_type_code: nil,
                                    description: nil)
    end

    def pm_subtypes
      @repo.find_pm_type_subtypes(@options[:id])
    end
  end
end
