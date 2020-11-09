# frozen_string_literal: true

module MasterfilesApp
  class FruitSizeRepo < BaseRepo # rubocop:disable Metrics/ClassLength
    build_for_select :basic_packs,
                     label: :basic_pack_code,
                     value: :id,
                     order_by: :basic_pack_code
    build_inactive_select :basic_packs,
                          label: :basic_pack_code,
                          value: :id,
                          order_by: :basic_pack_code

    build_for_select :standard_packs,
                     label: :standard_pack_code,
                     value: :id,
                     order_by: :standard_pack_code
    build_inactive_select :standard_packs,
                          label: :standard_pack_code,
                          value: :id,
                          order_by: :standard_pack_code

    build_for_select :standard_product_weights,
                     label: :id,
                     value: :id,
                     order_by: :id
    build_inactive_select :standard_product_weights,
                          label: :id,
                          value: :id,
                          order_by: :id

    build_for_select :standard_counts,
                     label: :size_count_value,
                     value: :id,
                     order_by: :size_count_value
    build_inactive_select :standard_counts,
                          label: :size_count_value,
                          value: :id,
                          order_by: :size_count_value

    build_for_select :actual_counts,
                     label: :actual_count_value,
                     value: :id,
                     order_by: :actual_count_value
    build_inactive_select :actual_counts,
                          label: :actual_count_value,
                          value: :id,
                          order_by: :actual_count_value

    build_for_select :size_references,
                     label: :size_reference,
                     value: :id,
                     order_by: :size_reference
    build_inactive_select :size_references,
                          label: :size_reference,
                          value: :id,
                          order_by: :size_reference

    crud_calls_for :basic_packs, name: :basic_pack, wrapper: BasicPack
    crud_calls_for :standard_packs, name: :standard_pack, wrapper: StandardPack
    crud_calls_for :standard_product_weights, name: :standard_product_weight, wrapper: StandardProductWeight
    crud_calls_for :standard_counts, name: :standard_count, wrapper: StandardCount
    crud_calls_for :actual_counts, name: :actual_count, wrapper: ActualCount
    crud_calls_for :size_references, name: :size_reference, wrapper: SizeReference

    def find_standard_product_weight_flat(id)
      find_with_association(:standard_product_weights,
                            id,
                            parent_tables: [{ parent_table: :commodities,
                                              columns: %i[commodity_code],
                                              flatten_columns: { commodity_code: :commodity_code } },
                                            { parent_table: :standard_packs,
                                              columns: %i[standard_pack_code],
                                              foreign_key: :standard_pack_id,
                                              flatten_columns: { standard_pack_code: :standard_pack_code } }],
                            wrapper: StandardProductWeightFlat)
    end

    def find_standard_pack_flat(id)
      find_with_association(:standard_packs,
                            id,
                            parent_tables: [{ parent_table: :basic_packs,
                                              columns: %i[basic_pack_code],
                                              flatten_columns: { basic_pack_code: :basic_pack_code } }],
                            wrapper: StandardPackFlat)
    end

    def delete_basic_pack(id)
      dependents = DB[:actual_counts].where(basic_pack_id: id).select_map(:id)
      return { error: 'This pack code is in use.' } unless dependents.empty?

      DB[:basic_packs].where(id: id).delete
      { success: true }
    end

    def create_standard_pack(attrs)
      if AppConst::BASE_PACK_EQUALS_STD_PACK
        base_pack_id = DB[:basic_packs].insert(basic_pack_code: attrs[:standard_pack_code])
        DB[:standard_packs].insert(attrs.to_h.merge(basic_pack_id: base_pack_id))
      else
        DB[:standard_packs].insert(attrs.to_h)
      end
    end

    def update_standard_pack(id, attrs)
      if AppConst::BASE_PACK_EQUALS_STD_PACK && attrs.to_h.key?(:standard_pack_code)
        bp_id = DB[:standard_packs].where(id: id).get(:basic_pack_id)
        DB[:basic_packs].where(id: bp_id).update(basic_pack_code: attrs[:standard_pack_code])
      end
      DB[:standard_packs].where(id: id).update(attrs.to_h)
    end

    def delete_standard_pack(id) # rubocop:disable Metrics/AbcSize
      dependents = standard_pack_code_dependents(id)
      return failed_response('This pack code is in use.') unless dependents.empty?

      bp_id = nil
      if AppConst::BASE_PACK_EQUALS_STD_PACK
        bp_id = DB[:standard_packs].where(id: id).get(:basic_pack_id)
        cnt = DB[:standard_packs].where(basic_pack_id: bp_id).count
        bp_id = nil if cnt > 1
      end

      DB[:standard_packs].where(id: id).delete
      DB[:basic_packs].where(id: bp_id).delete if bp_id
      ok_response
    end

    def delete_standard_count(id)
      DB[:actual_counts].where(standard_count_id: id).delete
      DB[:standard_counts].where(id: id).delete
    end

    def delete_actual_count(id)
      DB[:actual_counts].where(id: id).delete
    end

    def find_actual_count(id)
      hash = find_with_association(:actual_counts,
                                   id,
                                   parent_tables: [{ parent_table: :standard_counts,
                                                     columns: [:size_count_description],
                                                     flatten_columns: { size_count_description: :standard_count } },
                                                   { parent_table: :basic_packs,
                                                     columns: [:basic_pack_code],
                                                     flatten_columns: { basic_pack_code: :basic_pack_code } }],
                                   sub_tables: [{ sub_table: :size_references,
                                                  id_keys_column: :size_reference_ids,
                                                  columns: %i[id size_reference] },
                                                { sub_table: :standard_packs,
                                                  id_keys_column: :standard_pack_ids,
                                                  columns: %i[id standard_pack_code] }],
                                   lookup_functions: [],
                                   wrapper: nil)
      return nil if hash.nil?

      hash[:standard_packs] = hash[:standard_packs].map { |r| r[:standard_pack_code] }.sort.join(',')
      hash[:size_references] = hash[:size_references].map { |r| r[:size_reference] }.sort.join(',')
      ActualCount.new(hash)
    end

    def standard_packs(id)
      query = <<~SQL
        SELECT standard_packs.standard_pack_code
        FROM standard_packs
        JOIN actual_counts ON standard_packs.id = ANY (actual_counts.standard_pack_ids)
        WHERE actual_counts.id = #{id}
      SQL
      DB[query].order(:standard_pack_code).select_map(:standard_pack_code)
    end

    def size_references(id)
      query = <<~SQL
        SELECT size_references.size_reference
        FROM size_references
        JOIN actual_counts ON size_references.id = ANY (actual_counts.size_reference_ids)
        WHERE actual_counts.id = #{id}
      SQL
      DB[query].order(:size_reference).select_map(:size_reference)
    end

    def standard_pack_code_dependents(id)
      query = <<~SQL
        SELECT id
        FROM actual_counts
        WHERE #{id} = ANY (standard_pack_ids)
      SQL
      DB[query].select_map(:id)
    end

    def update_same_commodity_ratios(commodity_id, std_carton_nett_weight, standard_product_weight_id)
      standard_product_weight_ids = commodity_standard_product_weights(commodity_id, standard_product_weight_id)
      return if standard_product_weight_ids.empty?

      DB.execute(<<~SQL)
        UPDATE standard_product_weights SET ratio_to_standard_carton = (#{std_carton_nett_weight} / standard_carton_nett_weight)
        WHERE id IN (#{standard_product_weight_ids.join(',')});
      SQL
    end

    def commodity_standard_product_weights(commodity_id, standard_product_weight_id = nil)
      extra_conditions = standard_product_weight_id.nil? ? '' : " AND id != #{standard_product_weight_id}"
      query = <<~SQL
        SELECT id
        FROM standard_product_weights
        WHERE commodity_id = #{commodity_id} #{extra_conditions}
      SQL
      DB[query].select_map(:id)
    end

    def standard_carton_nett_weight(commodity_id)
      DB[:standard_product_weights]
        .where(commodity_id: commodity_id)
        .where(standard_carton: true)
        .get(:standard_carton_nett_weight)
    end

    def standard_carton_product_weights
      DB[:standard_product_weights]
        .where(standard_carton: true)
        .all
    end
  end
end
