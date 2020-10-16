# frozen_string_literal: true

module Masterfiles
  module Calendar
    module SeasonGroup
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:season_group, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              # form.caption 'Season Group'
              form.view_only!
              form.add_field :season_group_code
              form.add_field :description
              form.add_field :season_group_year
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end
