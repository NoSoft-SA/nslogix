# frozen_string_literal: true

module Masterfiles
  module Marketing
    module CustomerVariety
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:customer_variety, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'New Customer Variety'
              form.action '/masterfiles/marketing/customer_varieties'
              form.remote! if remote
              form.add_field :variety_as_customer_variety_id
              form.add_field :packed_tm_group_id
              form.add_field :customer_variety_varieties
            end
          end

          layout
        end
      end
    end
  end
end
