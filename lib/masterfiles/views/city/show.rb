# frozen_string_literal: true

module Masterfiles
  module TargetMarkets
    module City
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:city, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :region_name
              form.add_field :country_name
              form.add_field :city_name
            end
          end

          layout
        end
      end
    end
  end
end
