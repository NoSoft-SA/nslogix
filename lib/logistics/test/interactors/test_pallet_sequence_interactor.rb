# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module LogisticsApp
  class TestPalletSequenceInteractor < MiniTestWithHooks
    include PalletFactory
    include MasterfilesApp::FarmsFactory
    include MasterfilesApp::CultivarFactory
    include MasterfilesApp::FruitFactory
    include MasterfilesApp::CommodityFactory
    include MasterfilesApp::PartyFactory
    include MasterfilesApp::CalendarFactory
    include MasterfilesApp::TargetMarketFactory
    include MasterfilesApp::MarketingFactory

    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(LogisticsApp::PalletRepo)
    end

    def test_pallet_sequence
      LogisticsApp::PalletRepo.any_instance.stubs(:find_pallet_sequence).returns(fake_pallet_sequence)
      entity = interactor.send(:pallet_sequence, 1)
      assert entity.is_a?(PalletSequence)
    end

    def test_create_pallet_sequence
      attrs = fake_pallet_sequence.to_h.reject { |k, _| k == :id }
      res = interactor.create_pallet_sequence(attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(PalletSequence, res.instance)
      assert res.instance.id.nonzero?
    end

    def test_create_pallet_sequence_fail
      attrs = fake_pallet_sequence(pallet_number: nil).to_h.reject { |k, _| k == :id }
      res = interactor.create_pallet_sequence(attrs)
      refute res.success, 'should fail validation'
      assert_equal ['must be filled'], res.errors[:pallet_number]
    end

    def test_update_pallet_sequence
      id = create_pallet_sequence
      attrs = interactor.send(:repo).find_hash(:pallet_sequences, id).reject { |k, _| k == :id }

      value = attrs[:pallet_number]
      attrs[:pallet_number] = 'a_change'
      res = interactor.update_pallet_sequence(id, attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(PalletSequence, res.instance)
      assert_equal 'a_change', res.instance.pallet_number
      refute_equal value, res.instance.pallet_number
    end

    def test_update_pallet_sequence_fail
      id = create_pallet_sequence
      attrs = interactor.send(:repo).find_hash(:pallet_sequences, id).reject { |k, _| %i[id pallet_number].include?(k) }
      res = interactor.update_pallet_sequence(id, attrs)
      refute res.success, "#{res.message} : #{res.errors.inspect}"
      assert_equal ['is missing'], res.errors[:pallet_number]
    end

    def test_delete_pallet_sequence
      id = create_pallet_sequence
      assert_count_changed(:pallet_sequences, -1) do
        res = interactor.delete_pallet_sequence(id)
        assert res.success, res.message
      end
    end

    private

    def pallet_sequence_attrs
      pallet_id = create_pallet
      farm_id = create_farm
      puc_id = create_puc
      orchard_id = create_orchard
      cultivar_group_id = create_cultivar_group
      cultivar_id = create_cultivar
      season_id = create_season
      grade_id = create_grade
      marketing_variety_id = create_marketing_variety
      customer_variety_id = create_customer_variety
      standard_pack_id = create_standard_pack
      party_role_id = create_party_role
      target_market_group_id = create_target_market_group
      mark_id = create_mark
      inventory_code_id = create_inventory_code

      {
        id: 1,
        pallet_id: pallet_id,
        pallet_number: Faker::Lorem.unique.word,
        pallet_sequence_number: 1,
        farm_id: farm_id,
        puc_id: puc_id,
        orchard_id: orchard_id,
        cultivar_group_id: cultivar_group_id,
        cultivar_id: cultivar_id,
        season_id: season_id,
        grade_id: grade_id,
        marketing_variety_id: marketing_variety_id,
        customer_variety_id: customer_variety_id,
        standard_pack_id: standard_pack_id,
        marketing_org_party_role_id: party_role_id,
        packed_tm_group_id: target_market_group_id,
        mark_id: mark_id,
        inventory_code_id: inventory_code_id,
        extended_columns: {},
        client_size_reference: 'ABC',
        client_product_code: 'ABC',
        treatment_ids: [1, 2, 3],
        marketing_order_number: 'ABC',
        carton_quantity: 1,
        exit_ref: 'ABC',
        scrapped_at: '2010-01-01 12:00',
        nett_weight: 1.0,
        production_run: 'ABC',
        production_line: 'ABC',
        packhouse: 'ABC',
        pick_ref: 'ABC',
        sell_by_code: 'ABC',
        product_chars: 'ABC',
        repacked_at: '2010-01-01 12:00',
        failed_otmc_results: [1, 2, 3],
        phyto_data: 'ABC',
        active: true
      }
    end

    def fake_pallet_sequence(overrides = {})
      PalletSequence.new(pallet_sequence_attrs.merge(overrides))
    end

    def interactor
      @interactor ||= PalletSequenceInteractor.new(current_user, {}, {}, {})
    end
  end
end
