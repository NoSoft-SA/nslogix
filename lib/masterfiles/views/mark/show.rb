# frozen_string_literal: true

module Masterfiles
  module Marketing
    module Mark
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:mark, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              # form.caption 'Mark'
              form.view_only!
              form.add_field :mark_code
              form.add_field :description
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end
