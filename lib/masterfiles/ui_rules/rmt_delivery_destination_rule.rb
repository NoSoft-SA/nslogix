# frozen_string_literal: true

module UiRules
  class RmtDeliveryDestinationRule < Base
    def generate_rules
      @repo = MasterfilesApp::RmtDeliveryDestinationRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode

      form_name 'rmt_delivery_destination'
    end

    def set_show_fields
      fields[:delivery_destination_code] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
        delivery_destination_code: { required: true },
        description: {}
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_rmt_delivery_destination(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(delivery_destination_code: nil,
                                    description: nil)
    end
  end
end
