# frozen_string_literal: true

module Masterfiles
  module Fruit
    module ActualCounts
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:actual_count, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :standard_count_id
              form.add_field :basic_pack_id
              form.add_field :actual_count_value
              form.add_field :active
              form.add_field :standard_packs
              form.add_field :size_references
            end
          end

          layout
        end
      end
    end
  end
end
