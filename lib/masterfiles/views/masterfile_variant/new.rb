# frozen_string_literal: true

module Masterfiles
  module General
    module MasterfileVariant
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:masterfile_variant, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'New Masterfile Variant'
              form.action '/masterfiles/general/masterfile_variants'
              form.remote! if remote
              form.add_field :variant
              form.add_field :masterfile_table
              form.add_field :masterfile_id
              form.add_field :masterfile_code
              form.add_field :variant_code
            end
          end

          layout
        end
      end
    end
  end
end
