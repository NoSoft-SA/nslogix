# frozen_string_literal: true

module Masterfiles
  module Marketing
    module CustomerVariety
      class Edit
        def self.call(id, form_values: nil, form_errors: nil)
          ui_rule = UiRules::Compiler.new(:customer_variety, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'Edit Customer Variety'
              form.action "/masterfiles/marketing/customer_varieties/#{id}"
              form.remote!
              form.method :update
              form.add_field :variety_as_customer_variety_id
              form.add_field :packed_tm_group_id
            end
          end

          layout
        end
      end
    end
  end
end
