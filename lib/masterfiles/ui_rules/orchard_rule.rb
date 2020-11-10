# frozen_string_literal: true

module UiRules
  class OrchardRule < Base
    def generate_rules
      @repo = MasterfilesApp::FarmRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode

      form_name 'orchard'
    end

    def set_show_fields
      puc_id_label = @repo.find_puc(@form_object.puc_id)&.puc_code
      fields[:puc_id] = { renderer: :label, with_value: puc_id_label, caption: 'PUC' }
      fields[:orchard_code] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
      fields[:cultivar_ids] = { renderer: :list, items: cultivar_names, caption: 'Cultivars'  }
    end

    def common_fields
      {
        puc_id: { renderer: :select,
                  options: @repo.for_select_pucs,
                  disabled_options: @repo.for_select_inactive_pucs,
                  caption: 'PUC',
                  required: true },
        orchard_code: { required: true },
        description: {},
        active: { renderer: :checkbox },
        cultivar_ids: { renderer: :multi,
                        options: MasterfilesApp::CultivarRepo.new.for_select_cultivars,
                        selected: @form_object.cultivar_ids,
                        caption: 'Cultivars',
                        required: true }
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_orchard(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(puc_id: nil,
                                    orchard_code: nil,
                                    description: nil,
                                    active: true,
                                    cultivar_ids: [])
    end
  end
end
