# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
module Logistics
  module Pallets
    module PalletSequence
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:pallet_sequence, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'New Pallet Sequence'
              form.action '/logistics/pallets/pallet_sequences'
              form.remote! if remote
              form.add_field :pallet_id
              form.add_field :pallet_number
              form.add_field :pallet_sequence_number
              form.add_field :farm_id
              form.add_field :puc_id
              form.add_field :orchard_id
              form.add_field :cultivar_group_id
              form.add_field :cultivar_id
              form.add_field :season_id
              form.add_field :grade_id
              form.add_field :marketing_variety_id
              form.add_field :customer_variety_id
              form.add_field :standard_pack_id
              form.add_field :marketing_org_party_role_id
              form.add_field :packed_tm_group_id
              form.add_field :mark_id
              form.add_field :inventory_code_id
              form.add_field :extended_columns
              form.add_field :client_size_reference
              form.add_field :client_product_code
              form.add_field :treatment_ids
              form.add_field :marketing_order_number
              form.add_field :carton_quantity
              form.add_field :exit_ref
              form.add_field :scrapped_at
              form.add_field :nett_weight
              form.add_field :production_run
              form.add_field :production_line
              form.add_field :packhouse
              form.add_field :pick_ref
              form.add_field :sell_by_code
              form.add_field :product_chars
              form.add_field :repacked_at
              form.add_field :failed_otmc_results
              form.add_field :phyto_data
            end
          end

          layout
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
