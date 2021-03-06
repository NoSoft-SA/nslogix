# frozen_string_literal: true

module Masterfiles
  module HumanResources
    module EmploymentType
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:employment_type, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              # form.caption 'Employment Type'
              form.view_only!
              form.add_field :employment_type_code
            end
          end

          layout
        end
      end
    end
  end
end
