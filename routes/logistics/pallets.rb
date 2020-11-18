# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength, Metrics/BlockLength
class Nslogix < Roda
  route 'pallets', 'logistics' do |r|
    # PALLET SEQUENCES
    # --------------------------------------------------------------------------
    r.on 'pallet_sequences', Integer do |id|
      interactor = LogisticsApp::PalletSequenceInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      # Check for notfound:
      r.on !interactor.exists?(:pallet_sequences, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('pallets', 'edit')
        interactor.assert_permission!(:edit, id)
        show_partial { Logistics::Pallets::PalletSequence::Edit.call(id) }
      end

      r.is do
        r.get do       # SHOW
          check_auth!('pallets', 'read')
          show_partial { Logistics::Pallets::PalletSequence::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_pallet_sequence(id, params[:pallet_sequence])
          if res.success
            row_keys = %i[
              pallet_id
              pallet_number
              pallet_sequence_number
              farm_id
              puc_id
              orchard_id
              cultivar_group_id
              cultivar_id
              season_id
              grade_id
              marketing_variety_id
              customer_variety_id
              standard_pack_id
              marketing_org_party_role_id
              packed_tm_group_id
              mark_id
              inventory_code_id
              extended_columns
              client_size_reference
              client_product_code
              treatment_ids
              marketing_order_number
              carton_quantity
              exit_ref
              scrapped_at
              nett_weight
              production_run
              production_line
              packhouse
              pick_ref
              sell_by_code
              product_chars
              repacked_at
              failed_otmc_results
              phyto_data
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res) { Logistics::Pallets::PalletSequence::Edit.call(id, form_values: params[:pallet_sequence], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('pallets', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_pallet_sequence(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'pallet_sequences' do
      interactor = LogisticsApp::PalletSequenceInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
      r.on 'new' do    # NEW
        check_auth!('pallets', 'new')
        show_partial_or_page(r) { Logistics::Pallets::PalletSequence::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_pallet_sequence(params[:pallet_sequence])
        if res.success
          row_keys = %i[
            id
            pallet_id
            pallet_number
            pallet_sequence_number
            farm_id
            puc_id
            orchard_id
            cultivar_group_id
            cultivar_id
            season_id
            grade_id
            marketing_variety_id
            customer_variety_id
            standard_pack_id
            marketing_org_party_role_id
            packed_tm_group_id
            mark_id
            inventory_code_id
            extended_columns
            client_size_reference
            client_product_code
            treatment_ids
            marketing_order_number
            carton_quantity
            exit_ref
            scrapped_at
            nett_weight
            active
            production_run
            production_line
            packhouse
            pick_ref
            sell_by_code
            product_chars
            repacked_at
            failed_otmc_results
            phyto_data
          ]
          add_grid_row(attrs: select_attributes(res.instance, row_keys),
                       notice: res.message)
        else
          re_show_form(r, res, url: '/logistics/pallets/pallet_sequences/new') do
            Logistics::Pallets::PalletSequence::New.call(form_values: params[:pallet_sequence],
                                                         form_errors: res.errors,
                                                         remote: fetch?(r))
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength, Metrics/BlockLength
