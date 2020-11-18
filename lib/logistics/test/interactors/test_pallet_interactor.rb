# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module LogisticsApp
  class TestPalletInteractor < MiniTestWithHooks
    include PalletFactory

    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(LogisticsApp::PalletRepo)
    end

    def test_pallet
      LogisticsApp::PalletRepo.any_instance.stubs(:find_pallet).returns(fake_pallet)
      entity = interactor.send(:pallet, 1)
      assert entity.is_a?(Pallet)
    end

    def test_create_pallet
      attrs = fake_pallet.to_h.reject { |k, _| k == :id }
      res = interactor.create_pallet(attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(Pallet, res.instance)
      assert res.instance.id.nonzero?
    end

    def test_create_pallet_fail
      attrs = fake_pallet(pallet_number: nil).to_h.reject { |k, _| k == :id }
      res = interactor.create_pallet(attrs)
      refute res.success, 'should fail validation'
      assert_equal ['must be filled'], res.errors[:pallet_number]
    end

    def test_update_pallet
      id = create_pallet
      attrs = interactor.send(:repo).find_hash(:pallets, id).reject { |k, _| k == :id }
      value = attrs[:pallet_number]
      attrs[:pallet_number] = 'a_change'
      res = interactor.update_pallet(id, attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(Pallet, res.instance)
      assert_equal 'a_change', res.instance.pallet_number
      refute_equal value, res.instance.pallet_number
    end

    def test_update_pallet_fail
      id = create_pallet
      attrs = interactor.send(:repo).find_hash(:pallets, id).reject { |k, _| %i[id pallet_number].include?(k) }
      res = interactor.update_pallet(id, attrs)
      refute res.success, "#{res.message} : #{res.errors.inspect}"
      assert_equal ['is missing'], res.errors[:pallet_number]
    end

    def test_delete_pallet
      id = create_pallet
      assert_count_changed(:pallets, -1) do
        res = interactor.delete_pallet(id)
        assert res.success, res.message
      end
    end

    private

    def pallet_attrs
      edi_in_transaction_id = create_edi_in_transaction

      {
        id: 1,
        edi_in_transaction_id: edi_in_transaction_id,
        pallet_number: Faker::Lorem.unique.word,
        exit_ref: 'ABC',
        scrapped_at: '2010-01-01 12:00',
        shipped_at: '2010-01-01 12:00',
        shipped: false,
        stock_created_at: '2010-01-01 12:00',
        in_stock: false,
        inspected: false,
        govt_first_inspection_at: '2010-01-01 12:00',
        govt_reinspection_at: '2010-01-01 12:00',
        govt_inspection_passed: false,
        internal_inspection_passed: false,
        internal_inspection_at: '2010-01-01 12:00',
        internal_reinspection_at: '2010-01-01 12:00',
        phc: 'ABC',
        intake_created_at: '2010-01-01 12:00',
        first_cold_storage_at: '2010-01-01 12:00',
        cooled: false,
        gross_weight: 1.0,
        nett_weight: 1.0,
        weight_measured_at: '2010-01-01 12:00',
        on_site_location: 'ABC',
        consignment_note_number: 'ABC',
        original_consignment_note_number: 'ABC',
        inspection_point: 'ABC',
        original_inspection_point: 'ABC',
        carton_quantity: 1,
        allocated: false,
        allocated_at: '2010-01-01 12:00',
        reinspected: false,
        scrapped: false,
        repacked: false,
        repacked_at: '2010-01-01 12:00',
        temp_tail: 'ABC',
        active: true
      }
    end

    def fake_pallet(overrides = {})
      Pallet.new(pallet_attrs.merge(overrides))
    end

    def interactor
      @interactor ||= PalletInteractor.new(current_user, {}, {}, {})
    end
  end
end
