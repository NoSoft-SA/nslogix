# frozen_string_literal: true

module MasterfilesApp
  class MasterfileVariantRepo < BaseRepo
    crud_calls_for :masterfile_variants, name: :masterfile_variant, wrapper: MasterfileVariant

    def find_masterfile_variant_flat(id)
      hash = find_hash(:masterfile_variants, id)
      return nil if hash.nil?

      variant = lookup_mf_variant(hash[:masterfile_table])
      hash[:variant] = variant[:variant]
      hash[:masterfile_column] = variant[:column_name]
      hash[:masterfile_code] = get(hash[:masterfile_table].to_sym, hash[:masterfile_id], hash[:masterfile_column].to_sym)

      MasterfileVariantFlat.new(hash)
    end

    def for_select_mf_variant
      array = []
      AppConst::MF_VARIANT_RULES.each do |variant, hash|
        array << [variant.to_s.gsub('_', ' '), hash[:table_name]]
      end
      array
    end

    def lookup_mf_variant(table_name) # rubocop:disable Metrics/AbcSize
      return nil if table_name.to_s.nil_or_empty?

      variant = AppConst::MF_VARIANT_RULES.select { |_, hash| hash.key(table_name.to_s) }
      raise Crossbeams::FrameworkError, %("lookup_mf_variant" rule not defined for #{table_name}) if variant.nil_or_empty?

      { variant: variant.keys.first.to_s.gsub('_', ' '),
        table_name: table_name.to_sym,
        column_name: variant.values.first[:column_name].to_sym }
    end

    # Gets the id or variant id from a record matching on the args
    #
    # @param table_name [Symbol] the db table name.
    # @param args [Hash] the where-clause conditions.
    # @return [integer] the id value for the matching record or nil.
    def get_variant_id(table_name, args)
      id = get_id(table_name, args)
      return id unless id.nil?

      params = args.clone
      variant_code = params.delete(lookup_mf_variant(table_name)[:column_name])
      id = DB[:masterfile_variants].where(masterfile_table: table_name.to_s, variant_code: variant_code).get(:masterfile_id)
      return nil if id.nil?

      get_id(table_name, params.merge(id: id))
    end
  end
end
