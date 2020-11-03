# frozen_string_literal: true

module UiRules
  class UomTypeRule < Base
    def generate_rules
      @repo = MasterfilesApp::UomRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'uom_type'
    end

    def set_show_fields
      fields[:uom_type_code] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
          uom_type_code: { required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_uom_type(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(code: nil)
    end
  end
end
