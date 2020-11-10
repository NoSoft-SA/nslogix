# frozen_string_literal: true

module UiRules
  class BasicPackRule < Base
    def generate_rules
      @this_repo = MasterfilesApp::FruitSizeRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'basic_pack'
    end

    def set_show_fields
      fields[:basic_pack_code] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:length_mm] = { renderer: :label }
      fields[:width_mm] = { renderer: :label }
      fields[:height_mm] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
        basic_pack_code: { required: true },
        description: {},
        length_mm: { renderer: :integer },
        width_mm: { renderer: :integer },
        height_mm: { renderer: :integer }
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @this_repo.find_basic_pack(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(basic_pack_code: nil,
                                    description: nil,
                                    length_mm: nil,
                                    width_mm: nil,
                                    height_mm: nil)
    end
  end
end
