# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
class Nslogix < Roda # rubocop:disable Metrics/ClassLength
  route 'raw_materials', 'rmd' do |r|
    r.on 'dispatch' do
      # --------------------------------------------------------------------------
      # BIN LOADS
      # --------------------------------------------------------------------------
      r.on 'bin_load', Integer do |bin_load_id|
        interactor = RawMaterialsApp::BinLoadInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
        stepper = interactor.stepper(:bin_load)
        r.get do
          form_state = stepper.form_state
          r.redirect('/rmd/raw_materials/dispatch/bin_load') if form_state.empty?

          form = Crossbeams::RMDForm.new(form_state,
                                         form_name: :bin_load,
                                         progress: stepper.progress,
                                         scan_with_camera: @rmd_scan_with_camera,
                                         links: [{ caption: 'Cancel', url: '/rmd/raw_materials/dispatch/bin_load/clear', prompt: 'Cancel Bin Load?' }],
                                         notes: retrieve_from_local_store(:flash_notice),
                                         caption: 'Scan Bins',
                                         action: "/rmd/raw_materials/dispatch/bin_load/#{bin_load_id}",
                                         button_caption: 'Submit')

          form.add_label(:bin_load_id, 'Bin Load', bin_load_id)
          form.add_label(:customer, 'Customer', form_state[:customer])
          form.add_label(:transporter, 'Transporter', form_state[:transporter])
          form.add_label(:dest_depot, 'Destination Depot', form_state[:dest_depot])
          form.add_label(:qty_bins, 'qty Bins', form_state[:qty_bins])
          form.add_field(:bin_asset_number, 'Bin Asset Number', scan: 'key248_all', scan_type: :bin_asset, required: true, submit_form: true)

          form.add_csrf_tag csrf_tag
          view(inline: form.render, layout: :layout_rmd)
        end

        r.post do
          res = interactor.scan_bin_to_bin_load(params[:bin_load])
          if res.success
            stepper.allocate(res.instance)
            if stepper.ready_to_ship?
              res = interactor.allocate_and_ship_bin_load(bin_load_id, stepper.loaded)
              if res.success
                stepper.clear
                store_locally(:flash_notice, rmd_success_message(res.message))
                r.redirect('/rmd/raw_materials/dispatch/bin_load')
              else
                store_locally(:flash_notice, rmd_error_message(res.message))
              end
            end

            store_locally(:flash_notice, rmd_success_message(stepper.message)) if stepper.message
            store_locally(:flash_notice, rmd_warning_message(stepper.warning)) if stepper.warning
            store_locally(:flash_notice, rmd_error_message(stepper.error)) if stepper.error
          else
            store_locally(:flash_notice, rmd_error_message(res.message))
          end
          r.redirect("/rmd/raw_materials/dispatch/bin_load/#{bin_load_id}")
        end
      end

      r.on 'bin_load' do
        interactor = RawMaterialsApp::BinLoadInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
        stepper = interactor.stepper(:bin_load)
        r.on 'clear' do
          stepper.clear
          r.redirect('/rmd/raw_materials/dispatch/bin_load')
        end

        r.get do
          form_state = {}
          r.redirect("/rmd/raw_materials/dispatch/bin_load/#{stepper.bin_load_id}") unless stepper.bin_load_id.nil?

          form_state = stepper.form_state if stepper.error?
          form = Crossbeams::RMDForm.new(form_state,
                                         form_name: :bin_load,
                                         scan_with_camera: @rmd_scan_with_camera,
                                         notes: retrieve_from_local_store(:flash_notice),
                                         caption: 'Scan Bin Load',
                                         action: '/rmd/raw_materials/dispatch/bin_load',
                                         button_caption: 'Submit')

          form.add_field(:bin_load_id,
                         'Bin Load',
                         data_type: 'number',
                         scan: 'key248_all',
                         scan_type: :load,
                         submit_form: true,
                         required: true)
          form.add_csrf_tag csrf_tag
          view(inline: form.render, layout: :layout_rmd)
        end

        r.post do
          res = interactor.scan_bin_load(params[:bin_load])
          if res.success
            stepper.setup_load(res.instance.id)
            r.redirect("/rmd/raw_materials/dispatch/bin_load/#{res.instance.id}")
          else
            store_locally(:flash_notice, rmd_error_message(res.message))
            r.redirect('/rmd/raw_materials/dispatch/bin_load')
          end
        end
      end
    end

    # --------------------------------------------------------------------------
    # PALBIN LOADS
    # --------------------------------------------------------------------------
    r.on 'receive_bin' do
      interactor = RawMaterialsApp::RmtBinInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
      repo = RawMaterialsApp::RmtDeliveryRepo.new
      stepper = interactor.stepper(:receive_bin)

      r.on 'cancel' do
        stepper.clear
        r.redirect('/rmd/raw_materials/receive_bin')
      end

      r.on 'complete' do
        stepper.complete
        stepper.clear
        r.redirect('/rmd/home')
      end

      r.get do
        form_state = stepper.form_state
        form_state[:error_message] = retrieve_from_local_store(:flash_notice)
        form = Crossbeams::RMDForm.new(form_state,
                                       form_name: :receive_bin,
                                       progress: stepper.progress,
                                       scan_with_camera: @rmd_scan_with_camera,
                                       notes: stepper.notes,
                                       links: stepper.links,
                                       caption: 'Scan to Receive Bin',
                                       action: '/rmd/raw_materials/receive_bin',
                                       button_caption: 'Submit')
        hash = form_state[:entity]
        unless hash.nil_or_empty?
          form.add_label(:bin_asset_number, 'Bin Asset Number', hash[:bin_asset_number])
          form.add_label(:farm, 'Farm', hash[:farm_code])
          form.add_label(:puc, 'PUC', hash[:puc_code])
          form.add_label(:orchard, 'Orchard', hash[:orchard_code])
          form.add_label(:cultivar, 'Cultivar', hash[:cultivar_name])
          form.add_label(:class, 'Class', hash[:class_code])
          form.add_label(:pack, 'Pack', hash[:container_material_type_code])
          form.add_label(:gross_weight, 'Gross Weight', hash[:gross_weight])
          form.add_label(:nett_weight, 'Nett Weight', hash[:nett_weight])
        end

        form.add_field(:bin_asset_number,
                       'Bin Asset Number',
                       data_type: 'number',
                       scan: 'key248_all',
                       scan_type: :pallet_number,
                       submit_form: true,
                       required: true)

        form.add_csrf_tag csrf_tag
        view(inline: form.render, layout: :layout_rmd)
      end

      r.post do
        bin_asset_number = params[:receive_bin][:bin_asset_number]
        bin_id = repo.get_id(:rmt_bins, bin_asset_number: bin_asset_number)
        res = interactor.check(:receive, bin_id)
        if res.success
          stepper.scan(bin_asset_number)
        else
          store_locally(:flash_notice, rmd_error_message(res.message))
        end
        r.redirect('/rmd/raw_materials/receive_bin')
      end
    end
  end

  # --------------------------------------------------------------------------
  # DELIVERIES
  # --------------------------------------------------------------------------
  route 'rmt_deliveries', 'rmd' do |r| # rubocop:disable Metrics/BlockLength
    # --------------------------------------------------------------------------
    # BINS
    # --------------------------------------------------------------------------
    r.on 'rmt_bins', Integer do |id| # rubocop:disable Metrics/BlockLength
      interactor = RawMaterialsApp::RmtBinInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      r.on 'new' do # rubocop:disable Metrics/BlockLength    # NEW
        bin_delivery = RawMaterialsApp::RmtDeliveryRepo.new.get_bin_delivery(id)
        default_rmt_container_type = RawMaterialsApp::RmtDeliveryRepo.new.rmt_container_type_by_container_type_code(AppConst::DELIVERY_DEFAULT_RMT_CONTAINER_TYPE)
        details = retrieve_from_local_store(:bin) || { cultivar_id: bin_delivery[:cultivar_id], bin_fullness: :Full }

        capture_inner_bins = AppConst::DELIVERY_CAPTURE_INNER_BINS && !default_rmt_container_type[:id].nil? && MasterfilesApp::RmtContainerTypeRepo.new.find_container_type(default_rmt_container_type[:id])&.rmt_inner_container_type_id
        capture_nett_weight = AppConst::DELIVERY_CAPTURE_BIN_WEIGHT_AT_FRUIT_RECEPTION
        capture_container_material = AppConst::DELIVERY_CAPTURE_CONTAINER_MATERIAL
        capture_container_material_owner = AppConst::DELIVERY_CAPTURE_CONTAINER_MATERIAL_OWNER

        form = Crossbeams::RMDForm.new(details,
                                       form_name: :rmt_bin,
                                       scan_with_camera: @rmd_scan_with_camera,
                                       caption: 'New Bin',
                                       action: "/rmd/rmt_deliveries/rmt_bins/#{id}/rmt_bins",
                                       button_caption: 'Submit')

        form.behaviours do |behaviour|
          behaviour.dropdown_change :rmt_container_type_id, notify: [{ url: '/rmd/rmt_deliveries/rmt_bins/rmt_bin_rmt_container_type_combo_changed' }] if capture_container_material
          behaviour.dropdown_change :rmt_container_material_type_id, notify: [{ url: '/rmd/rmt_deliveries/rmt_bins/rmt_bin_container_material_type_combo_changed' }] if capture_container_material && capture_container_material_owner
        end

        form.add_label(:farm_code, 'Farm', bin_delivery[:farm_code], nil, as_table_cell: true)
        form.add_label(:puc_code, 'Puc', bin_delivery[:puc_code], nil, as_table_cell: true)
        form.add_label(:orchard_code, 'Orchard', bin_delivery[:orchard_code], nil, as_table_cell: true)
        form.add_label(:date_picked, 'Date Picked', bin_delivery[:date_picked], nil, as_table_cell: true)
        form.add_label(:date_delivered, 'Date Delivered', bin_delivery[:date_delivered], nil, as_table_cell: true)
        form.add_label(:qty_bins_tipped, 'Qty Bins Tipped', bin_delivery[:qty_bins_tipped], nil, as_table_cell: true)
        form.add_label(:qty_bins_received, 'Qty Bins Received', bin_delivery[:qty_bins_received], nil, as_table_cell: true)
        form.add_select(:rmt_class_id, 'Rmt Class', items: MasterfilesApp::FruitRepo.new.for_select_rmt_classes, prompt: true, required: false)
        form.add_select(:rmt_container_type_id, 'Container Type', items: MasterfilesApp::RmtContainerTypeRepo.new.for_select_rmt_container_types, value: default_rmt_container_type[:id],
                                                                  required: true, prompt: true)
        form.add_label(:qty_bins, 'Qty Bins', 1, 1)
        if capture_inner_bins
          form.add_field(:qty_inner_bins, 'Qty Inner Bins', data_type: 'number')
        else
          form.add_label(:qty_inner_bins, 'Qty Inner Bins', '1', '1', hide_on_load: true)
        end
        form.add_select(:bin_fullness, 'Bin Fullness', items: %w[Quarter Half Three\ Quarters Full], prompt: true)
        form.add_field(:nett_weight, 'Nett Weight', required: false) if capture_nett_weight

        if capture_container_material
          form.add_select(:rmt_container_material_type_id, 'Container Material Type',
                          items: MasterfilesApp::RmtContainerMaterialTypeRepo.new.for_select_rmt_container_material_types(where: { rmt_container_type_id: default_rmt_container_type[:id] }),
                          required: true, prompt: true)
        end

        if capture_container_material && capture_container_material_owner
          form.add_select(:rmt_material_owner_party_role_id, 'Container Material Owner',
                          items: !details[:rmt_container_material_type_id].to_s.empty? ? RawMaterialsApp::RmtDeliveryRepo.new.find_container_material_owners_by_container_material_type(details[:rmt_container_material_type_id]) : [],
                          required: true, prompt: true)
        end

        form.add_field(:bin_asset_number, 'Asset Number', scan: 'key248_all', scan_type: :bin_asset, required: true)
        form.add_csrf_tag csrf_tag
        view(inline: form.render, layout: :layout_rmd)
      end

      r.post do # CREATE
        res = interactor.create_rmt_bin(id, params[:rmt_bin])
        if res.success
          flash[:notice] = 'Bin Created Successfully'
          r.redirect("/raw_materials/deliveries/rmt_deliveries/#{id}/edit")
        else
          params[:rmt_bin][:error_message] = res.message
          params[:rmt_bin][:errors] = res.errors
          store_locally(:bin, params[:rmt_bin])
          r.redirect("/rmd/rmt_deliveries/rmt_bins/#{id}/new")
        end
      end
    end

    r.on 'rmt_bins' do # rubocop:disable Metrics/BlockLength
      interactor = RawMaterialsApp::RmtBinInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      r.on 'rmt_bin_rmt_container_type_combo_changed' do
        rmt_container_type_combo_changed('rmt_bin')
      end

      r.on 'rmt_bin_container_material_type_combo_changed' do
        container_material_type_combo_changed('rmt_bin')
      end

      # --------------------------------------------------------------------------
      # MOVE RMT BIN
      # --------------------------------------------------------------------------
      r.on 'move_rmt_bin' do
        r.get do
          notice = retrieve_from_local_store(:flash_notice)
          form_state = {}
          error = retrieve_from_local_store(:errors)
          form_state.merge!(error_message: error[:error_message], errors:  { bin_number: [''] }) unless error.nil?
          form = Crossbeams::RMDForm.new(form_state,
                                         form_name: :bin,
                                         notes: notice,
                                         scan_with_camera: @rmd_scan_with_camera,
                                         caption: 'Scan Bin',
                                         action: '/rmd/rmt_deliveries/rmt_bins/move_rmt_bin',
                                         button_caption: 'Submit')
          form.add_field(:bin_number, 'Bin Number', scan: 'key248_all', scan_type: :bin_asset, required: true, submit_form: true)
          form.add_csrf_tag csrf_tag
          view(inline: form.render, layout: :layout_rmd)
        end

        r.post do
          res = interactor.validate_bin(params[:bin][:bin_number])
          if res.success
            r.redirect("/rmd/rmt_deliveries/rmt_bins/scan_location/#{res.instance[:id]}")
          else
            store_locally(:errors, error_message: "Error: #{unwrap_failed_response(res)}")
            r.redirect('/rmd/rmt_deliveries/rmt_bins/move_rmt_bin')
          end
        end
      end

      r.on 'scan_location', Integer do |id|
        r.get do
          bin = RawMaterialsApp::RmtDeliveryRepo.new.find_rmt_bin(id)
          notice = retrieve_from_local_store(:flash_notice)
          form_state = {}
          error = retrieve_from_local_store(:errors)
          form_state.merge!(error_message: error[:error_message], errors:  { location: [''] }) unless error.nil?
          form = Crossbeams::RMDForm.new(form_state,
                                         form_name: :bin,
                                         notes: notice,
                                         scan_with_camera: @rmd_scan_with_camera,
                                         caption: 'Scan Bin',
                                         action: "/rmd/rmt_deliveries/rmt_bins/move_rmt_bin_submit/#{id}",
                                         button_caption: 'Move Bin')
          form.add_label(:bin_number, 'Bin Number', AppConst::USE_PERMANENT_RMT_BIN_BARCODES ? bin[:bin_asset_number] : bin[:id])
          form.add_field(:location, 'Location', scan: 'key248_all', scan_type: :location, submit_form: true, required: true, lookup: false)
          form.add_csrf_tag csrf_tag
          view(inline: form.render, layout: :layout_rmd)
        end
      end

      r.on 'move_rmt_bin_submit', Integer do |id|
        res = interactor.move_bin(id, params[:bin][:location], params[:bin][:location_scan_field])
        if res.success
          store_locally(:flash_notice, unwrap_failed_response(res))
          r.redirect('/rmd/rmt_deliveries/rmt_bins/move_rmt_bin')
        else
          store_locally(:errors, error_message: "Error: #{unwrap_failed_response(res)}")
          r.redirect("/rmd/rmt_deliveries/rmt_bins/scan_location/#{id}")
        end
      end

      # --------------------------------------------------------------------------
      # CREATE RMT REBIN
      # --------------------------------------------------------------------------
      r.on 'create_rebin' do # rubocop:disable Metrics/BlockLength
        r.get do # rubocop:disable Metrics/BlockLength
          form_state = { bin_fullness: :Full }
          error = retrieve_from_local_store(:errors)
          notice = retrieve_from_local_store(:flash_notice)
          if (details = retrieve_from_local_store(:form_state))
            prod_run = ProductionApp::ProductionRunRepo.new.find_production_run_flat(details[:production_run_rebin_id])
            details.merge!(prod_run.to_h)
          end
          form_state.merge!(error_message: error[:error_message], errors:  {}) unless error.nil?
          form_state.merge!(details) unless details.nil?

          default_rmt_container_type = RawMaterialsApp::RmtDeliveryRepo.new.rmt_container_type_by_container_type_code(AppConst::DELIVERY_DEFAULT_RMT_CONTAINER_TYPE)
          capture_container_material = AppConst::DELIVERY_CAPTURE_CONTAINER_MATERIAL
          capture_container_material_owner = AppConst::DELIVERY_CAPTURE_CONTAINER_MATERIAL_OWNER

          form = Crossbeams::RMDForm.new(form_state,
                                         notes: notice,
                                         form_name: :rmt_bin,
                                         scan_with_camera: @rmd_scan_with_camera,
                                         caption: 'Create Rebin',
                                         reset_button: false,
                                         action: '/rmd/rmt_deliveries/rmt_bins/create_rebin',
                                         button_caption: 'Submit')

          form.behaviours do |behaviour|
            behaviour.dropdown_change :production_line_id, notify: [{ url: '/rmd/rmt_deliveries/rmt_bins/rmt_bin_production_line_id_combo_changed' }]
            behaviour.dropdown_change :production_run_rebin_id, notify: [{ url: '/rmd/rmt_deliveries/rmt_bins/rmt_bin_production_run_rebin_id_combo_changed' }]
            behaviour.input_change :bin_asset_number, notify: [{ url: '/rmd/rmt_deliveries/rmt_bins/bin_asset_number_changed' }]
            behaviour.dropdown_change :rmt_container_material_type_id, notify: [{ url: '/rmd/rmt_deliveries/rmt_bins/rmt_bin_rebin_container_material_type_combo_changed', param_keys: %i[rmt_bin_bin_asset_number] }] if capture_container_material && capture_container_material_owner
          end

          form.add_field(:bin_asset_number, 'Bin Number', scan: 'key248_all', scan_type: :bin_asset, required: true, submit_form: false)
          form.add_select(:rmt_class_id, 'Rmt Class', items: MasterfilesApp::FruitRepo.new.for_select_rmt_classes, prompt: true, required: true)
          form.add_select(:production_line_id, 'Production Line', items: ProductionApp::ResourceRepo.new.for_select_plant_resources_of_type('LINE'), prompt: true, required: true)
          form.add_select(:production_run_rebin_id, 'Production Run', items: form_state[:production_line_id] ? ProductionApp::ProductionRunRepo.new.for_select_production_runs_for_line(form_state[:production_line_id]) : [], prompt: true, required: true)
          form.add_label(:farm, 'Farm', form_state[:farm_code])
          form.add_label(:puc, 'Puc', form_state[:puc_code])
          form.add_label(:orchard, 'Orchard', form_state[:orchard_code])
          form.add_label(:cultivar, 'Cultivar', form_state[:cultivar_name])
          form.add_label(:cultivar_group, 'Cultivar Group', form_state[:cultivar_group_code])
          form.add_label(:season, 'Season', form_state[:season_code])
          form.add_select(:bin_fullness, 'Bin Fullness', items: %w[Quarter Half Three\ Quarters Full], prompt: true)

          if capture_container_material
            form.add_select(:rmt_container_material_type_id, 'Container Material Type',
                            items: MasterfilesApp::RmtContainerMaterialTypeRepo.new.for_select_rmt_container_material_types(where: { rmt_container_type_id: default_rmt_container_type[:id] }),
                            required: true, prompt: true)
          end

          if capture_container_material && capture_container_material_owner
            form.add_select(:rmt_material_owner_party_role_id, 'Container Material Owner',
                            items: !details.nil? && !details[:rmt_container_material_type_id].to_s.empty? ? RawMaterialsApp::RmtDeliveryRepo.new.find_container_material_owners_by_container_material_type(details[:rmt_container_material_type_id]) : [],
                            required: true, prompt: true)
          end

          form.add_field(:gross_weight, 'Gross Weight', data_type: 'number')
          form.add_csrf_tag csrf_tag
          view(inline: form.render, layout: :layout_rmd)
        end

        r.post do
          res = interactor.create_rebin(params[:rmt_bin])
          if res.success
            store_locally(:flash_notice, "Rebin: #{params[:rmt_bin][:bin_asset_number]} created successfully")
          else
            store_locally(:errors, error_message: "Error: #{unwrap_failed_response(res)}")
            params[:rmt_bin][:bin_asset_number] = nil
            store_locally(:form_state, params[:rmt_bin])
          end
          r.redirect('/rmd/rmt_deliveries/rmt_bins/create_rebin')
        end
      end

      r.on 'rmt_bin_production_line_id_combo_changed' do
        actions = [OpenStruct.new(type: :replace_inner_html,
                                  dom_id: 'rmt_bin_orchard_value',
                                  value: '&nbsp;'),
                   OpenStruct.new(type: :replace_inner_html,
                                  dom_id: 'rmt_bin_season_value',
                                  value: '&nbsp;'),
                   OpenStruct.new(type: :replace_inner_html,
                                  dom_id: 'rmt_bin_cultivar_value',
                                  value: '&nbsp;')]
        if !params[:changed_value].to_s.empty?
          production_runs = ProductionApp::ProductionRunRepo.new.for_select_production_runs_for_line(params[:changed_value])
          production_runs.unshift([[]])
          actions << OpenStruct.new(type: :replace_select_options,
                                    dom_id: 'rmt_bin_production_run_rebin_id',
                                    options_array: production_runs)
        else
          actions << OpenStruct.new(type: :replace_select_options,
                                    dom_id: 'rmt_bin_production_run_rebin_id',
                                    options_array: [])
        end
        json_actions(actions)
      end

      r.on 'bin_asset_number_changed' do
        repo = MasterfilesApp::RmtContainerMaterialTypeRepo.new
        default_rmt_container_type_id = RawMaterialsApp::RmtDeliveryRepo.new.rmt_container_type_by_container_type_code(AppConst::DELIVERY_DEFAULT_RMT_CONTAINER_TYPE)[:id]
        items = repo.for_select_rmt_container_material_types(where: { rmt_container_type_id: default_rmt_container_type_id })
        items.unshift([[]])
        container_material_owners = []
        if (default_rmt_container_material_type = repo.find_bin_rmt_container_material_type(params[:changed_value])) && items.include?([default_rmt_container_material_type[:container_material_type_code], default_rmt_container_material_type[:id]])
          items.unshift([default_rmt_container_material_type[:container_material_type_code], default_rmt_container_material_type[:id]])
          container_material_owners = RawMaterialsApp::RmtDeliveryRepo.new.find_container_material_owners_by_container_material_type(default_rmt_container_material_type[:id])
          container_material_owners.unshift([[]])
        end

        actions = [OpenStruct.new(type: :replace_select_options,
                                  dom_id: 'rmt_bin_rmt_container_material_type_id',
                                  options_array: items.uniq),
                   OpenStruct.new(type: :replace_select_options,
                                  dom_id: 'rmt_bin_rmt_material_owner_party_role_id',
                                  options_array: container_material_owners)]
        json_actions(actions)
      end

      r.on 'rmt_bin_rebin_container_material_type_combo_changed' do
        if !params[:changed_value].to_s.empty?
          params[:rmt_bin_bin_asset_number]
          container_material_owners = RawMaterialsApp::RmtDeliveryRepo.new.find_container_material_owners_by_container_material_type(params[:changed_value])
          container_material_owners.unshift([[]])
          json_replace_select_options('rmt_bin_rmt_material_owner_party_role_id', container_material_owners)
        else
          json_replace_select_options('rmt_bin_rmt_material_owner_party_role_id', [])
        end
      end

      r.on 'rmt_bin_production_run_rebin_id_combo_changed' do # rubocop:disable Metrics/BlockLength
        actions = if !params[:changed_value].to_s.empty?
                    prod_run = ProductionApp::ProductionRunRepo.new.find_production_run_flat(params[:changed_value])
                    [OpenStruct.new(type: :replace_inner_html,
                                    dom_id: 'rmt_bin_orchard_value',
                                    value: prod_run[:orchard_code]),
                     OpenStruct.new(type: :replace_inner_html,
                                    dom_id: 'rmt_bin_season_value',
                                    value: prod_run[:season_code]),
                     OpenStruct.new(type: :replace_inner_html,
                                    dom_id: 'rmt_bin_farm_value',
                                    value: prod_run[:farm_code]),
                     OpenStruct.new(type: :replace_inner_html,
                                    dom_id: 'rmt_bin_puc_value',
                                    value: prod_run[:puc_code]),
                     OpenStruct.new(type: :replace_inner_html,
                                    dom_id: 'rmt_bin_cultivar_group_value',
                                    value: prod_run[:cultivar_group_code]),
                     OpenStruct.new(type: :replace_inner_html,
                                    dom_id: 'rmt_bin_cultivar_value',
                                    value: prod_run[:cultivar_name])]
                  else
                    [OpenStruct.new(type: :replace_inner_html,
                                    dom_id: 'rmt_bin_orchard_value',
                                    value: '&nbsp;'),
                     OpenStruct.new(type: :replace_inner_html,
                                    dom_id: 'rmt_bin_season_value',
                                    value: '&nbsp;'),
                     OpenStruct.new(type: :replace_inner_html,
                                    dom_id: 'rmt_bin_farm_value',
                                    value: '&nbsp;'),
                     OpenStruct.new(type: :replace_inner_html,
                                    dom_id: 'rmt_bin_puc_value',
                                    value: '&nbsp;'),
                     OpenStruct.new(type: :replace_inner_html,
                                    dom_id: 'rmt_bin_cultivar_group_value',
                                    value: '&nbsp;'),
                     OpenStruct.new(type: :replace_inner_html,
                                    dom_id: 'rmt_bin_cultivar_value',
                                    value: '&nbsp;')]
                  end
        json_actions(actions)
      end

      # --------------------------------------------------------------------------
      # EDIT RMT BIN
      # --------------------------------------------------------------------------
      r.on 'edit_rmt_bin' do
        r.get do
          notice = retrieve_from_local_store(:flash_notice)
          form_state = {}
          error = retrieve_from_local_store(:errors)
          form_state.merge!(error_message: error[:error_message], errors:  { bin_number: [''] }) unless error.nil?
          form = Crossbeams::RMDForm.new(form_state,
                                         form_name: :bin,
                                         notes: notice,
                                         scan_with_camera: @rmd_scan_with_camera,
                                         caption: 'Scan Bin',
                                         action: '/rmd/rmt_deliveries/rmt_bins/edit_rmt_bin',
                                         button_caption: 'Submit')
          form.add_field(:bin_number, 'Bin Number', scan: 'key248_all', scan_type: :bin_asset, required: true, submit_form: true)
          form.add_csrf_tag csrf_tag
          view(inline: form.render, layout: :layout_rmd)
        end

        r.post do
          res = interactor.validate_bin(params[:bin][:bin_number])
          if res.success
            r.redirect("/rmd/rmt_deliveries/rmt_bins/render_edit_rmt_bin/#{res.instance[:id]}")
          else
            store_locally(:errors, error_message: "Error: #{unwrap_failed_response(res)}")
            r.redirect('/rmd/rmt_deliveries/rmt_bins/edit_rmt_bin')
          end
        end
      end

      r.on 'render_edit_rmt_bin', Integer do |id| # rubocop:disable Metrics/BlockLength
        bin = interactor.bin_details(id)
        form_state = { bin_fullness: bin[:bin_fullness], qty_bins: bin[:qty_bins] }
        error = retrieve_from_local_store(:errors)
        form_state.merge!(error_message: error[:error_message], errors:  { delivery_number: [''] }) unless error.nil?

        form = Crossbeams::RMDForm.new(form_state,
                                       notes: nil,
                                       form_name: :rmt_bin,
                                       scan_with_camera: @rmd_scan_with_camera,
                                       caption: 'Update Bin',
                                       reset_button: false,
                                       no_submit: false,
                                       action: "/rmd/rmt_deliveries/rmt_bins/edit_rmt_bin_submit/#{bin[:id]}",
                                       button_caption: 'Update')

        capture_container_material = AppConst::DELIVERY_CAPTURE_CONTAINER_MATERIAL
        capture_container_material_owner = AppConst::DELIVERY_CAPTURE_CONTAINER_MATERIAL_OWNER

        form.behaviours do |behaviour|
          behaviour.dropdown_change :rmt_container_type_id, notify: [{ url: '/rmd/rmt_deliveries/rmt_bins/bin_edit_rmt_container_type_combo_changed' }] if capture_container_material
          behaviour.dropdown_change :rmt_container_material_type_id, notify: [{ url: '/rmd/rmt_deliveries/rmt_bins/bin_edit_container_material_type_combo_changed' }] if capture_container_material && capture_container_material_owner
        end

        form.add_label(:delivery_number, 'Delivery Number', bin[:rmt_delivery_id])
        form.add_label(:farm_code, 'Farm', bin[:farm_code])
        form.add_label(:puc_code, 'Puc', bin[:puc_code])
        form.add_label(:orchard_code, 'Orchard', bin[:orchard_code])
        form.add_label(:cultivar_name, 'Cultivar', bin[:cultivar_name])
        form.add_field(:qty_bins, 'Qty Bins', hide_on_load: true)
        form.add_select(:bin_fullness, 'Bin Fullness', items: %w[Quarter Half Three\ Quarters Full], prompt: true)
        form.add_select(:rmt_container_type_id, 'Container Type', items: MasterfilesApp::RmtContainerTypeRepo.new.for_select_rmt_container_types, value: bin[:rmt_container_type_id], required: true, prompt: true)

        if capture_container_material
          form.add_select(:rmt_container_material_type_id, 'Container Material Type',
                          items: MasterfilesApp::RmtContainerMaterialTypeRepo.new.for_select_rmt_container_material_types(where: { rmt_container_type_id: bin[:rmt_container_type_id] }),
                          required: true, prompt: true, value: bin[:rmt_container_material_type_id])
        end

        if capture_container_material && capture_container_material_owner
          form.add_select(:rmt_material_owner_party_role_id, 'Container Material Owner',
                          items: RawMaterialsApp::RmtDeliveryRepo.new.find_container_material_owners_by_container_material_type(bin[:rmt_container_material_type_id]),
                          required: true, prompt: true, value: bin[:rmt_material_owner_party_role_id])
        end
        form.add_csrf_tag csrf_tag
        view(inline: form.render, layout: :layout_rmd)
      end

      r.on 'edit_rmt_bin_submit', Integer do |id|
        res = interactor.pdt_update_rmt_bin(id, params[:rmt_bin])
        if res.success
          store_locally(:flash_notice, "Bin: #{id} Updated Successfully")
          r.redirect('/rmd/rmt_deliveries/rmt_bins/edit_rmt_bin')
        else
          store_locally(:errors, error_message: "Error: #{unwrap_failed_response(res)}")
          r.redirect("/rmd/rmt_deliveries/rmt_bins/render_edit_rmt_bin/#{id}")
        end
      end

      # --------------------------------------------------------------------------
      # BIN RECEPTION SCANNING
      # --------------------------------------------------------------------------
      r.on 'bin_reception_scanning' do
        r.get do
          notice = retrieve_from_local_store(:flash_notice)
          form_state = {}
          error = retrieve_from_local_store(:errors)
          form_state.merge!(error_message: error[:error_message], errors:  { delivery_number: [''] }) unless error.nil?
          form = Crossbeams::RMDForm.new(form_state,
                                         form_name: :bin_reception,
                                         notes: notice,
                                         scan_with_camera: @rmd_scan_with_camera,
                                         caption: 'Scan Delivery',
                                         action: '/rmd/rmt_deliveries/rmt_bins/bin_reception_scanning',
                                         button_caption: 'Submit')
          form.add_field(:delivery_number, 'Delivery', scan: 'key248_all', scan_type: :delivery, data_type: 'number', submit_form: true, required: false)
          form.add_csrf_tag csrf_tag
          view(inline: form.render, layout: :layout_rmd)
        end

        r.post do
          res = interactor.validate_delivery(params[:bin_reception][:delivery_number])
          if res.success
            r.redirect("/rmd/rmt_deliveries/rmt_bins/delivery_confirmation/#{params[:bin_reception][:delivery_number]}")
          else
            store_locally(:errors, error_message: "Error: #{unwrap_failed_response(res)}")
            r.redirect('/rmd/rmt_deliveries/rmt_bins/bin_reception_scanning')
          end
        end
      end

      r.on 'delivery_confirmation', Integer do |id|
        delivery = interactor.get_delivery_confirmation_details(id)
        form = Crossbeams::RMDForm.new({},
                                       notes: nil,
                                       form_name: :delivery,
                                       scan_with_camera: @rmd_scan_with_camera,
                                       caption: 'Confirm Delivery',
                                       reset_button: false,
                                       no_submit: false,
                                       action: "/rmd/rmt_deliveries/rmt_bins/cancel_bin_reception/#{id}",
                                       button_caption: 'Cancel')
        form.add_label(:delivery_number, 'Delivery Number', delivery[:id])
        form.add_label(:cultivar_group_code, 'Cultivar Group', delivery[:cultivar_group_code])
        form.add_label(:cultivar_name, 'Cultivar', delivery[:cultivar_name])
        form.add_label(:farm_code, 'Farm', delivery[:farm_code])
        form.add_label(:puc_code, 'Puc', delivery[:puc_code])
        form.add_label(:orchard_code, 'Orchard', delivery[:orchard_code])
        form.add_label(:truck_registration_number, 'Truck Reg Number', delivery[:truck_registration_number])
        form.add_label(:date_delivered, 'Date Delivered', delivery[:date_delivered])
        form.add_label(:bins_received, 'Bins Received', delivery[:bins_received])
        form.add_label(:qty_bins_remaining, 'Qty Bins Remaining', delivery[:qty_bins_remaining])
        form.add_button('Next', "/rmd/rmt_deliveries/rmt_bins/receive_rmt_bins/#{id}")
        form.add_csrf_tag csrf_tag
        view(inline: form.render, layout: :layout_rmd)
      end

      r.on 'cancel_bin_reception', Integer do |id|
        store_locally(:flash_notice, "Bin Reception For Delivery: #{id} Cancelled Successfully")
        r.redirect('/rmd/rmt_deliveries/rmt_bins/bin_reception_scanning')
      end

      r.on 'bin_reception_rmt_container_type_combo_changed' do
        rmt_container_type_combo_changed('delivery')
      end

      r.on 'bin_reception_container_material_type_combo_changed' do
        # container_material_type_combo_changed('delivery')
        if !params[:changed_value].to_s.empty?
          container_material_owners = RawMaterialsApp::RmtDeliveryRepo.new.find_container_material_owners_for_container_material_type(params[:changed_value])
          container_material_owners.unshift([[]])
          json_replace_select_options('delivery_rmt_material_owner_party_role_id', container_material_owners)
        else
          json_replace_select_options('delivery_rmt_material_owner_party_role_id', [])
        end
      end

      r.on 'bin_edit_rmt_container_type_combo_changed' do
        rmt_container_type_combo_changed('rmt_bin')
      end

      r.on 'bin_edit_container_material_type_combo_changed' do
        container_material_type_combo_changed('rmt_bin')
      end

      r.on 'receive_rmt_bins', Integer do |id| # rubocop:disable Metrics/BlockLength
        delivery = interactor.get_delivery_confirmation_details(id)
        default_rmt_container_type = RawMaterialsApp::RmtDeliveryRepo.new.rmt_container_type_by_container_type_code(AppConst::DELIVERY_DEFAULT_RMT_CONTAINER_TYPE)

        capture_container_material = AppConst::DELIVERY_CAPTURE_CONTAINER_MATERIAL
        capture_container_material_owner = AppConst::DELIVERY_CAPTURE_CONTAINER_MATERIAL_OWNER
        capture_inner_bins = AppConst::DELIVERY_CAPTURE_INNER_BINS && !default_rmt_container_type[:id].nil? && MasterfilesApp::RmtContainerTypeRepo.new.find_container_type(default_rmt_container_type[:id])&.rmt_inner_container_type_id

        notice = retrieve_from_local_store(:flash_notice)
        rmt_container_material_type_id = retrieve_from_local_store(:rmt_container_material_type_id)
        rmt_material_owner_party_role_id = retrieve_from_local_store(:rmt_material_owner_party_role_id)
        form_state = { bin_fullness: :Full, qty_bins: 1, rmt_container_material_type_id: rmt_container_material_type_id, rmt_material_owner_party_role_id: rmt_material_owner_party_role_id }
        error = retrieve_from_local_store(:errors)
        form_state.merge!(error_message: error[:message], errors: error[:errors]) unless error.nil?
        form = Crossbeams::RMDForm.new(form_state,
                                       notes: notice,
                                       form_name: :delivery,
                                       scan_with_camera: @rmd_scan_with_camera,
                                       caption: 'Receive Bins',
                                       reset_button: false,
                                       no_submit: false,
                                       action: "/rmd/rmt_deliveries/rmt_bins/receive_rmt_bins_submit/#{id}",
                                       button_caption: 'Submit')

        form.behaviours do |behaviour|
          behaviour.dropdown_change :rmt_container_type_id, notify: [{ url: '/rmd/rmt_deliveries/rmt_bins/bin_reception_rmt_container_type_combo_changed' }] if capture_container_material
          behaviour.dropdown_change :rmt_container_material_type_id, notify: [{ url: '/rmd/rmt_deliveries/rmt_bins/bin_reception_container_material_type_combo_changed' }] if capture_container_material && capture_container_material_owner
        end

        form.add_label(:delivery_number, 'Delivery Number', delivery[:id])
        form.add_label(:cultivar_group_code, 'Cultivar Group', delivery[:cultivar_group_code])
        form.add_label(:cultivar_name, 'Cultivar', delivery[:cultivar_name])
        form.add_label(:farm_code, 'Farm', delivery[:farm_code])
        form.add_label(:puc_code, 'Puc', delivery[:puc_code])
        form.add_label(:orchard_code, 'Orchard', delivery[:orchard_code])
        form.add_label(:bins_received, 'Bins Received', delivery[:bins_received])
        form.add_label(:qty_bins_remaining, 'Qty Bins Remaining', delivery[:qty_bins_remaining])
        form.add_select(:rmt_container_type_id, 'Container Type', items: MasterfilesApp::RmtContainerTypeRepo.new.for_select_rmt_container_types, value: default_rmt_container_type[:id], required: true, prompt: true)
        form.add_select(:rmt_class_id, 'Rmt Class', items: MasterfilesApp::FruitRepo.new.for_select_rmt_classes, prompt: true, required: false)

        if capture_container_material
          form.add_select(:rmt_container_material_type_id, 'Container Material Type',
                          items: MasterfilesApp::RmtContainerMaterialTypeRepo.new.for_select_rmt_container_material_types(where: { rmt_container_type_id: default_rmt_container_type[:id] }),
                          required: true, prompt: true)
        end

        if capture_container_material && capture_container_material_owner
          rmt_material_owner_party_role_ids = rmt_container_material_type_id ? RawMaterialsApp::RmtDeliveryRepo.new.find_container_material_owners_by_container_material_type(rmt_container_material_type_id) : []
          form.add_select(:rmt_material_owner_party_role_id, 'Container Material Owner',
                          items: rmt_material_owner_party_role_ids,
                          required: true, prompt: true)
        end

        form.add_field(:bin_fullness, 'Bin Fullness', hide_on_load: true)
        form.add_field(:qty_bins, 'Qty Bins', hide_on_load: true)
        if capture_inner_bins
          form.add_field(:qty_inner_bins, 'Qty Inner Bins', data_type: 'number')
        else
          form.add_label(:qty_inner_bins, 'Qty Inner Bins', '1', '1', hide_on_load: true)
        end

        form.add_field(:bin_asset_number1, 'Asset Number1', scan: 'key248_all', scan_type: :bin_asset, submit_form: false, required: true)
        delivery[:qty_bins_remaining] = AppConst::BIN_SCANNING_BATCH_SIZE.to_i unless delivery[:qty_bins_remaining] < AppConst::BIN_SCANNING_BATCH_SIZE.to_i
        if delivery[:qty_bins_remaining] > 1
          (1..(delivery[:qty_bins_remaining] - 1)).each do |c|
            form.add_field("bin_asset_number#{c + 1}".to_sym, "Asset Number#{c + 1}", scan: 'key248_all', scan_type: :bin_asset, submit_form: false, required: false)
          end
        end

        form.add_csrf_tag csrf_tag
        view(inline: form.render, layout: :layout_rmd)
      end

      r.on 'receive_rmt_bins_submit', Integer do |id|
        params[:delivery].delete_if { |_k, v| v.nil_or_empty? }
        params[:delivery].delete_if { |k, _v| k.to_s.include?('scan_field') }
        res = interactor.create_rmt_bins(id, params[:delivery])
        if res.success
          delivery = interactor.get_delivery_confirmation_details(id)
          if delivery[:qty_bins_remaining].positive?
            store_locally(:flash_notice, res.message)
            r.redirect("/rmd/rmt_deliveries/rmt_bins/receive_rmt_bins/#{id}")
          else
            store_locally(:flash_notice, "All #{delivery[:bins_received]} bins for delivery:#{id} have already been received(scanned) successfully")
            r.redirect("/rmd/rmt_deliveries/rmt_bins/set_bin_level/#{id}")
          end
        else
          store_locally(:errors, res)
          store_locally(:rmt_container_material_type_id, params[:delivery][:rmt_container_material_type_id])
          store_locally(:rmt_material_owner_party_role_id, params[:delivery][:rmt_material_owner_party_role_id])
          r.redirect("/rmd/rmt_deliveries/rmt_bins/receive_rmt_bins/#{id}")
        end
      end

      r.on 'set_bin_level', Integer do |id|
        notice = retrieve_from_local_store(:flash_notice)
        form_state = { bin_fullness: :Full }

        error = retrieve_from_local_store(:errors)
        form_state.merge!(error_message: error[:message], errors: error[:errors]) unless error.nil?

        form = Crossbeams::RMDForm.new(form_state,
                                       notes: notice,
                                       form_name: :bin,
                                       scan_with_camera: @rmd_scan_with_camera,
                                       caption: 'Set Bin Level',
                                       reset_button: false,
                                       no_submit: false,
                                       action: "/rmd/rmt_deliveries/rmt_bins/set_bin_level_complete/#{id}",
                                       button_caption: 'Finish')

        form.add_field(:bin_asset_number, 'Asset Number', scan: 'key248_all', scan_type: :bin_asset, required: true, submit_form: false)
        form.add_select(:bin_fullness, 'Bin Fullness', items: %w[Quarter Half Three\ Quarters Full], prompt: true)
        form.add_button('Next Bin', "/rmd/rmt_deliveries/rmt_bins/set_bin_level_next/#{id}")
        form.add_csrf_tag csrf_tag
        view(inline: form.render, layout: :layout_rmd)
      end

      r.on 'set_bin_level_next', Integer do |id|
        if RawMaterialsApp::RmtDeliveryRepo.new.exists?(:rmt_bins, bin_asset_number: params[:bin][:bin_asset_number], rmt_delivery_id: id)
          store_locally(:flash_notice, "Bin:#{params[:bin][:bin_asset_number]} level set to: #{params[:bin][:bin_fullness]} successfully")
          interactor.update_rmt_bin_asset_level(params[:bin][:bin_asset_number], params[:bin][:bin_fullness])
        else
          store_locally(:errors, message:  "Bin:#{params[:bin][:bin_asset_number]} does not belong to the scanned delivery:#{id}")
        end
        r.redirect("/rmd/rmt_deliveries/rmt_bins/set_bin_level/#{id}")
      end

      r.on 'set_bin_level_complete', Integer do |id| # rubocop:disable Metrics/BlockLength
        if RawMaterialsApp::RmtDeliveryRepo.new.exists?(:rmt_bins, bin_asset_number: params[:bin][:bin_asset_number], rmt_delivery_id: id)
          store_locally(:flash_notice, "Bin:#{params[:bin][:bin_asset_number]} level set to: #{params[:bin][:bin_fullness]} successfully")
          interactor.update_rmt_bin_asset_level(params[:bin][:bin_asset_number], params[:bin][:bin_fullness])

          delivery = interactor.get_delivery_confirmation_details(id)
          form = Crossbeams::RMDForm.new({},
                                         notes: nil,
                                         form_name: :delivery,
                                         scan_with_camera: @rmd_scan_with_camera,
                                         caption: 'Delivery',
                                         reset_button: false,
                                         no_submit: true,
                                         action: '',
                                         button_caption: 'Cancel')
          form.add_label(:delivery_number, 'Delivery Number', delivery[:id])
          form.add_label(:cultivar_group_code, 'Cultivar Group', delivery[:cultivar_group_code])
          form.add_label(:cultivar_name, 'Cultivar', delivery[:cultivar_name])
          form.add_label(:farm_code, 'Farm', delivery[:farm_code])
          form.add_label(:puc_code, 'Puc', delivery[:puc_code])
          form.add_label(:orchard_code, 'Orchard', delivery[:orchard_code])
          form.add_label(:truck_registration_number, 'Truck Reg Number', delivery[:truck_registration_number])
          form.add_label(:date_delivered, 'Date Delivered', delivery[:date_delivered])
          form.add_csrf_tag csrf_tag
          view(inline: form.render, layout: :layout_rmd)

        else
          store_locally(:errors, message:  "Bin:#{params[:bin][:bin_asset_number]} does not belong to the scanned delivery:#{id}")
          r.redirect("/rmd/rmt_deliveries/rmt_bins/set_bin_level/#{id}")
        end
      end
    end
  end

  def rmt_container_type_combo_changed(form_name) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    actions = []
    if !params[:changed_value].to_s.empty?
      rmt_container_material_type_ids = MasterfilesApp::RmtContainerMaterialTypeRepo.new.for_select_rmt_container_material_types(where: { rmt_container_type_id: params[:changed_value] })
      rmt_container_material_type_ids.unshift([[]])
      if AppConst::DELIVERY_CAPTURE_CONTAINER_MATERIAL
        actions << OpenStruct.new(type: :replace_select_options,
                                  dom_id: "#{form_name}_rmt_container_material_type_id",
                                  options_array: rmt_container_material_type_ids)
      end
      if AppConst::DELIVERY_CAPTURE_CONTAINER_MATERIAL && AppConst::DELIVERY_CAPTURE_INNER_BINS
        actions << OpenStruct.new(type: MasterfilesApp::RmtContainerTypeRepo.new.find_container_type(params[:changed_value])&.rmt_inner_container_type_id ? :show_element : :hide_element,
                                  dom_id: "#{form_name}_qty_inner_bins_row")
      end
    else
      if AppConst::DELIVERY_CAPTURE_CONTAINER_MATERIAL
        actions << OpenStruct.new(type: :replace_select_options,
                                  dom_id: "#{form_name}_rmt_container_material_type_id",
                                  options_array: [])
      end
      if AppConst::DELIVERY_CAPTURE_CONTAINER_MATERIAL && AppConst::DELIVERY_CAPTURE_INNER_BINS
        actions << OpenStruct.new(type: :hide_element,
                                  dom_id: "#{form_name}_qty_inner_bins_row")
      end
    end

    if AppConst::DELIVERY_CAPTURE_CONTAINER_MATERIAL && AppConst::DELIVERY_CAPTURE_CONTAINER_MATERIAL_OWNER
      actions << OpenStruct.new(type: :replace_select_options,
                                dom_id: "#{form_name}_rmt_material_owner_party_role_id",
                                options_array: [])
    end

    json_actions(actions)
  end

  def container_material_type_combo_changed(form_name)
    if !params[:changed_value].to_s.empty?
      container_material_owners = RawMaterialsApp::RmtDeliveryRepo.new.find_container_material_owners_by_container_material_type(params[:changed_value])
      container_material_owners.unshift([[]])
      json_replace_select_options("#{form_name}_rmt_material_owner_party_role_id", container_material_owners)
    else
      json_replace_select_options("#{form_name}_rmt_material_owner_party_role_id", [])
    end
  end
end
# rubocop:enable Metrics/BlockLength
