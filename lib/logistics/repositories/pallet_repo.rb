# frozen_string_literal: true

module LogisticsApp
  class PalletRepo < BaseRepo
    build_for_select :pallets, label: :pallet_number, value: :id, order_by: :pallet_number
    build_inactive_select :pallets, label: :pallet_number, value: :id, order_by: :pallet_number
    crud_calls_for :pallets, name: :pallet, wrapper: Pallet

    build_for_select :pallet_sequences,  label: :pallet_number, value: :id, order_by: :pallet_number
    build_inactive_select :pallet_sequences, label: :pallet_number, value: :id, order_by: :pallet_number
    crud_calls_for :pallet_sequences, name: :pallet_sequence, wrapper: PalletSequence

    def find_pallet(args)
      id = args.is_a?(Integer) ? args : get_id(:pallets, pallet_number: args[:pallet_number])
      find_with_association(:pallets,
                            id,
                            wrapper: Pallet)
    end

    def find_pallet_sequence(args)
      identifiers = %i[pallet_number pallet_sequence_number pallet_id]
      id = args.is_a?(Integer) ? args : get_id(:pallet_sequences, args.to_h.slice(identifiers).reject(&:nil?))
      find_with_association(:pallet_sequences,
                            id,
                            wrapper: PalletSequence)
    end

    def create_pallet_quarantine(flow_type, pallet_number, pallet_sequence_data, error)
      args = {
        flow_type: flow_type,
        pallet_number: pallet_number,
        record_data: [pallet_sequence_data.to_h],
        record_errors: [error.to_h]
      }

      id = get_id(:pallet_quarantine, pallet_number: pallet_number)
      if id
        args[:record_data] << get(:pallet_quarantine, id, :record_data)
        args[:record_errors] << get(:pallet_quarantine, id, :record_errors)

        update(:pallet_quarantine, id, args)
      else
        create(:pallet_quarantine, args)
      end
    end

    def delete_pallet_quarantine(pallet_number)
      id = get_id(:pallet_quarantine, pallet_number: pallet_number)
      delete(:pallet_quarantine, id)
    end
  end
end
