# frozen_string_literal: true

module UiRules
  class TreatmentRule < Base
    def generate_rules
      @repo = MasterfilesApp::FruitRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode

      form_name 'treatment'
    end

    def set_show_fields
      # treatment_type_id_label = MasterfilesApp::TreatmentTypeRepo.new.find_treatment_type(@form_object.treatment_type_id)&.treatment_type_code
      treatment_type_id_label = @repo.find(:treatment_types, MasterfilesApp::TreatmentType, @form_object.treatment_type_id)&.treatment_type_code
      fields[:treatment_type_id] = { renderer: :label, with_value: treatment_type_id_label, caption: 'Treatment Type' }
      fields[:treatment_code] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
        treatment_type_id: { renderer: :select, options: @repo.for_select_treatment_types, disabled_options: @repo.for_select_inactive_treatment_types, caption: 'treatment_type', required: true },
        treatment_code: { required: true },
        description: {}
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_treatment(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(treatment_type_id: nil,
                                    treatment_code: nil,
                                    description: nil)
    end
  end
end
