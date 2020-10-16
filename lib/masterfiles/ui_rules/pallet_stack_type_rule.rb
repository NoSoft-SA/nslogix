# frozen_string_literal: true

module UiRules
  class PalletStackTypeRule < Base
    def generate_rules
      @repo = MasterfilesApp::PackagingRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode

      form_name 'pallet_stack_type'
    end

    def set_show_fields
      fields[:stack_type_code] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:stack_height] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
      fields[:pallet_formats] = { renderer: :list, items: pallet_stack_type_pallet_formats }
    end

    def common_fields
      {
        stack_type_code: { required: true },
        description: {},
        stack_height: { renderer: :integer, required: true }
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_pallet_stack_type(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(stack_type_code: nil,
                                    description: nil,
                                    stack_height: nil)
    end

    def pallet_stack_type_pallet_formats
      @repo.find_pallet_stack_type_pallet_formats(@options[:id])
    end
  end
end
