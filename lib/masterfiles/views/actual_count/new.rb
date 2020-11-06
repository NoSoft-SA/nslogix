# frozen_string_literal: true

module Masterfiles
  module Fruit
    module ActualCounts
      class New
        def self.call(parent_id, form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:actual_count, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/masterfiles/fruit/standard_counts/#{parent_id}/actual_counts"
              form.remote! if remote
              # form.add_field :standard_count_id
              form.add_field :basic_pack_id
              form.add_field :actual_count_value
              form.add_field :standard_pack_ids
              form.add_field :size_reference_ids
            end
          end

          layout
        end
      end
    end
  end
end
