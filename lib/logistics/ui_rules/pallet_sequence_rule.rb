# frozen_string_literal: true

module UiRules
  class PalletSequenceRule < Base # rubocop:disable Metrics/ClassLength
    def generate_rules
      @repo = LogisticsApp::PalletRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode
      # set_complete_fields if @mode == :complete
      # set_approve_fields if @mode == :approve

      # add_approve_behaviours if @mode == :approve

      form_name 'pallet_sequence'
    end

    def set_show_fields # rubocop:disable Metrics/AbcSize
      # pallet_id_label = LogisticsApp::PalletRepo.new.find_pallet(@form_object.pallet_id)&.pallet_number
      pallet_id_label = @repo.find(:pallets, LogisticsApp::Pallet, @form_object.pallet_id)&.pallet_number
      # farm_id_label = LogisticsApp::FarmRepo.new.find_farm(@form_object.farm_id)&.farm_code
      farm_id_label = @repo.find(:farms, LogisticsApp::Farm, @form_object.farm_id)&.farm_code
      # puc_id_label = LogisticsApp::PucRepo.new.find_puc(@form_object.puc_id)&.puc_code
      puc_id_label = @repo.find(:pucs, LogisticsApp::Puc, @form_object.puc_id)&.puc_code
      # orchard_id_label = LogisticsApp::OrchardRepo.new.find_orchard(@form_object.orchard_id)&.orchard_code
      orchard_id_label = @repo.find(:orchards, LogisticsApp::Orchard, @form_object.orchard_id)&.orchard_code
      # cultivar_group_id_label = LogisticsApp::CultivarGroupRepo.new.find_cultivar_group(@form_object.cultivar_group_id)&.cultivar_group_code
      cultivar_group_id_label = @repo.find(:cultivar_groups, LogisticsApp::CultivarGroup, @form_object.cultivar_group_id)&.cultivar_group_code
      # cultivar_id_label = LogisticsApp::CultivarRepo.new.find_cultivar(@form_object.cultivar_id)&.cultivar_code
      cultivar_id_label = @repo.find(:cultivars, LogisticsApp::Cultivar, @form_object.cultivar_id)&.cultivar_code
      # season_id_label = LogisticsApp::SeasonRepo.new.find_season(@form_object.season_id)&.season_code
      season_id_label = @repo.find(:seasons, LogisticsApp::Season, @form_object.season_id)&.season_code
      # grade_id_label = LogisticsApp::GradeRepo.new.find_grade(@form_object.grade_id)&.grade_code
      grade_id_label = @repo.find(:grades, LogisticsApp::Grade, @form_object.grade_id)&.grade_code
      # marketing_variety_id_label = LogisticsApp::MarketingVarietyRepo.new.find_marketing_variety(@form_object.marketing_variety_id)&.marketing_variety_code
      marketing_variety_id_label = @repo.find(:marketing_varieties, LogisticsApp::MarketingVariety, @form_object.marketing_variety_id)&.marketing_variety_code
      # customer_variety_id_label = LogisticsApp::CustomerVarietyRepo.new.find_customer_variety(@form_object.customer_variety_id)&.id
      customer_variety_id_label = @repo.find(:customer_varieties, LogisticsApp::CustomerVariety, @form_object.customer_variety_id)&.id
      # standard_pack_id_label = LogisticsApp::StandardPackRepo.new.find_standard_pack(@form_object.standard_pack_id)&.standard_pack_code
      standard_pack_id_label = @repo.find(:standard_packs, LogisticsApp::StandardPack, @form_object.standard_pack_id)&.standard_pack_code
      # marketing_org_party_role_id_label = LogisticsApp::PartyRoleRepo.new.find_party_role(@form_object.marketing_org_party_role_id)&.id
      marketing_org_party_role_id_label = @repo.find(:party_roles, LogisticsApp::PartyRole, @form_object.marketing_org_party_role_id)&.id
      # packed_tm_group_id_label = LogisticsApp::TargetMarketGroupRepo.new.find_target_market_group(@form_object.packed_tm_group_id)&.target_market_group_name
      packed_tm_group_id_label = @repo.find(:target_market_groups, LogisticsApp::TargetMarketGroup, @form_object.packed_tm_group_id)&.target_market_group_name
      # mark_id_label = LogisticsApp::MarkRepo.new.find_mark(@form_object.mark_id)&.mark_code
      mark_id_label = @repo.find(:marks, LogisticsApp::Mark, @form_object.mark_id)&.mark_code
      # inventory_code_id_label = LogisticsApp::InventoryCodeRepo.new.find_inventory_code(@form_object.inventory_code_id)&.inventory_code
      inventory_code_id_label = @repo.find(:inventory_codes, LogisticsApp::InventoryCode, @form_object.inventory_code_id)&.inventory_code
      fields[:pallet_id] = { renderer: :label, with_value: pallet_id_label, caption: 'Pallet' }
      fields[:pallet_number] = { renderer: :label }
      fields[:pallet_sequence_number] = { renderer: :label }
      fields[:farm_id] = { renderer: :label, with_value: farm_id_label, caption: 'Farm' }
      fields[:puc_id] = { renderer: :label, with_value: puc_id_label, caption: 'PUC' }
      fields[:orchard_id] = { renderer: :label, with_value: orchard_id_label, caption: 'Orchard' }
      fields[:cultivar_group_id] = { renderer: :label, with_value: cultivar_group_id_label, caption: 'Cultivar Group' }
      fields[:cultivar_id] = { renderer: :label, with_value: cultivar_id_label, caption: 'Cultivar' }
      fields[:season_id] = { renderer: :label, with_value: season_id_label, caption: 'Season' }
      fields[:grade_id] = { renderer: :label, with_value: grade_id_label, caption: 'Grade' }
      fields[:marketing_variety_id] = { renderer: :label, with_value: marketing_variety_id_label, caption: 'Marketing Variety' }
      fields[:customer_variety_id] = { renderer: :label, with_value: customer_variety_id_label, caption: 'Customer Variety' }
      fields[:standard_pack_id] = { renderer: :label, with_value: standard_pack_id_label, caption: 'Standard Pack' }
      fields[:marketing_org_party_role_id] = { renderer: :label, with_value: marketing_org_party_role_id_label, caption: 'Marketing Org Party Role' }
      fields[:packed_tm_group_id] = { renderer: :label, with_value: packed_tm_group_id_label, caption: 'Packed Tm Group' }
      fields[:mark_id] = { renderer: :label, with_value: mark_id_label, caption: 'Mark' }
      fields[:inventory_code_id] = { renderer: :label, with_value: inventory_code_id_label, caption: 'Inventory Code' }
      fields[:extended_columns] = { renderer: :label }
      fields[:client_size_reference] = { renderer: :label }
      fields[:client_product_code] = { renderer: :label }
      fields[:treatment_ids] = { renderer: :label }
      fields[:marketing_order_number] = { renderer: :label }
      fields[:carton_quantity] = { renderer: :label }
      fields[:exit_ref] = { renderer: :label }
      fields[:scrapped_at] = { renderer: :label, format: :without_timezone_or_seconds }
      fields[:nett_weight] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
      fields[:production_run] = { renderer: :label }
      fields[:production_line] = { renderer: :label }
      fields[:packhouse] = { renderer: :label }
      fields[:pick_ref] = { renderer: :label }
      fields[:sell_by_code] = { renderer: :label }
      fields[:product_chars] = { renderer: :label }
      fields[:repacked_at] = { renderer: :label, format: :without_timezone_or_seconds }
      fields[:failed_otmc_results] = { renderer: :label }
      fields[:phyto_data] = { renderer: :label }
    end

    # def set_approve_fields
    #   set_show_fields
    #   fields[:approve_action] = { renderer: :select, options: [%w[Approve a], %w[Reject r]], required: true }
    #   fields[:reject_reason] = { renderer: :textarea, disabled: true }
    # end

    # def set_complete_fields
    #   set_show_fields
    #   user_repo = DevelopmentApp::UserRepo.new
    #   fields[:to] = { renderer: :select, options: user_repo.email_addresses(user_email_group: AppConst::EMAIL_GROUP_PALLET_SEQUENCE_APPROVERS), caption: 'Email address of person to notify', required: true }
    # end

    def common_fields # rubocop:disable Metrics/AbcSize
      {
        pallet_id: { renderer: :select, options: LogisticsApp::PalletRepo.new.for_select_pallets, disabled_options: LogisticsApp::PalletRepo.new.for_select_inactive_pallets, caption: 'Pallet' },
        pallet_number: { required: true },
        pallet_sequence_number: { required: true },
        farm_id: { renderer: :select, options: LogisticsApp::FarmRepo.new.for_select_farms, disabled_options: LogisticsApp::FarmRepo.new.for_select_inactive_farms, caption: 'Farm', required: true },
        puc_id: { renderer: :select, options: LogisticsApp::PucRepo.new.for_select_pucs, disabled_options: LogisticsApp::PucRepo.new.for_select_inactive_pucs, caption: 'Puc', required: true },
        orchard_id: { renderer: :select, options: LogisticsApp::OrchardRepo.new.for_select_orchards, disabled_options: LogisticsApp::OrchardRepo.new.for_select_inactive_orchards, caption: 'Orchard', required: true },
        cultivar_group_id: { renderer: :select, options: LogisticsApp::CultivarGroupRepo.new.for_select_cultivar_groups, disabled_options: LogisticsApp::CultivarGroupRepo.new.for_select_inactive_cultivar_groups, caption: 'Cultivar Group', required: true },
        cultivar_id: { renderer: :select, options: LogisticsApp::CultivarRepo.new.for_select_cultivars, disabled_options: LogisticsApp::CultivarRepo.new.for_select_inactive_cultivars, caption: 'Cultivar' },
        season_id: { renderer: :select, options: LogisticsApp::SeasonRepo.new.for_select_seasons, disabled_options: LogisticsApp::SeasonRepo.new.for_select_inactive_seasons, caption: 'Season', required: true },
        grade_id: { renderer: :select, options: LogisticsApp::GradeRepo.new.for_select_grades, disabled_options: LogisticsApp::GradeRepo.new.for_select_inactive_grades, caption: 'Grade', required: true },
        marketing_variety_id: { renderer: :select, options: LogisticsApp::MarketingVarietyRepo.new.for_select_marketing_varieties, disabled_options: LogisticsApp::MarketingVarietyRepo.new.for_select_inactive_marketing_varieties, caption: 'Marketing Variety', required: true },
        customer_variety_id: { renderer: :select, options: LogisticsApp::CustomerVarietyRepo.new.for_select_customer_varieties, disabled_options: LogisticsApp::CustomerVarietyRepo.new.for_select_inactive_customer_varieties, caption: 'Customer Variety' },
        standard_pack_id: { renderer: :select, options: LogisticsApp::StandardPackRepo.new.for_select_standard_packs, disabled_options: LogisticsApp::StandardPackRepo.new.for_select_inactive_standard_packs, caption: 'Standard Pack', required: true },
        marketing_org_party_role_id: { renderer: :select, options: LogisticsApp::PartyRoleRepo.new.for_select_party_roles, disabled_options: LogisticsApp::PartyRoleRepo.new.for_select_inactive_party_roles, caption: 'Marketing Org Party Role', required: true },
        packed_tm_group_id: { renderer: :select, options: LogisticsApp::TargetMarketGroupRepo.new.for_select_target_market_groups, disabled_options: LogisticsApp::TargetMarketGroupRepo.new.for_select_inactive_target_market_groups, caption: 'Packed Tm Group', required: true },
        mark_id: { renderer: :select, options: LogisticsApp::MarkRepo.new.for_select_marks, disabled_options: LogisticsApp::MarkRepo.new.for_select_inactive_marks, caption: 'Mark', required: true },
        inventory_code_id: { renderer: :select, options: LogisticsApp::InventoryCodeRepo.new.for_select_inventory_codes, disabled_options: LogisticsApp::InventoryCodeRepo.new.for_select_inactive_inventory_codes, caption: 'Inventory Code', required: true },
        extended_columns: {},
        client_size_reference: {},
        client_product_code: {},
        treatment_ids: {},
        marketing_order_number: {},
        carton_quantity: { required: true },
        exit_ref: {},
        scrapped_at: {},
        nett_weight: {},
        production_run: {},
        production_line: {},
        packhouse: {},
        pick_ref: {},
        sell_by_code: {},
        product_chars: {},
        repacked_at: {},
        failed_otmc_results: {},
        phyto_data: {}
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_pallet_sequence(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(pallet_id: nil,
                                    pallet_number: nil,
                                    pallet_sequence_number: nil,
                                    farm_id: nil,
                                    puc_id: nil,
                                    orchard_id: nil,
                                    cultivar_group_id: nil,
                                    cultivar_id: nil,
                                    season_id: nil,
                                    grade_id: nil,
                                    marketing_variety_id: nil,
                                    customer_variety_id: nil,
                                    standard_pack_id: nil,
                                    marketing_org_party_role_id: nil,
                                    packed_tm_group_id: nil,
                                    mark_id: nil,
                                    inventory_code_id: nil,
                                    extended_columns: nil,
                                    client_size_reference: nil,
                                    client_product_code: nil,
                                    treatment_ids: nil,
                                    marketing_order_number: nil,
                                    carton_quantity: nil,
                                    exit_ref: nil,
                                    scrapped_at: nil,
                                    nett_weight: nil,
                                    production_run: nil,
                                    production_line: nil,
                                    packhouse: nil,
                                    pick_ref: nil,
                                    sell_by_code: nil,
                                    product_chars: nil,
                                    repacked_at: nil,
                                    failed_otmc_results: nil,
                                    phyto_data: nil)
    end

    # private

    # def add_approve_behaviours
    #   behaviours do |behaviour|
    #     behaviour.enable :reject_reason, when: :approve_action, changes_to: ['r']
    #   end
    # end
  end
end
