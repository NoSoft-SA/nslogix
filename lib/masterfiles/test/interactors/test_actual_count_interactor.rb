# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestActualCountsInteractor < MiniTestWithHooks
    include GeneralFactory
    include FruitFactory
    include CommodityFactory

    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(MasterfilesApp::FruitSizeRepo)
    end

    def test_actual_count
      MasterfilesApp::FruitSizeRepo.any_instance.stubs(:find_actual_count).returns(fake_actual_count)
      entity = interactor.send(:actual_count, 1)
      assert entity.is_a?(ActualCount)
    end

    def test_create_actual_count
      attrs = fake_actual_count.to_h.reject { |k, _| k == :id }
      attrs = attrs.to_h
      res = interactor.create_actual_count(attrs[:standard_count_id], attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(ActualCount, res.instance)
      assert res.instance.id.nonzero?
    end

    def test_create_actual_count_fail
      attrs = fake_actual_count(basic_pack_id: nil).to_h.reject { |k, _| k == :id }
      attrs = attrs.to_h
      res = interactor.create_actual_count(attrs[:standard_count_id], attrs)
      refute res.success, 'should fail validation'
      assert_equal ['must be filled'], res.errors[:basic_pack_id]
    end

    def test_update_actual_count
      id = create_actual_count
      attrs = interactor.send(:repo).find_actual_count(id)
      attrs = attrs.to_h
      value = attrs[:actual_count_value]
      attrs[:actual_count_value] = 20
      res = interactor.update_actual_count(id, attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(ActualCount, res.instance)
      assert_equal 20, res.instance.actual_count_value
      refute_equal value, res.instance.actual_count_value
    end

    def test_update_actual_count_fail
      id = create_actual_count
      attrs = interactor.send(:repo).find_actual_count(id)
      attrs = attrs.to_h
      attrs.delete(:basic_pack_id)
      value = attrs[:actual_count_value]
      attrs[:actual_count_value] = 20
      res = interactor.update_actual_count(id, attrs)
      refute res.success, "#{res.message} : #{res.errors.inspect}"
      assert_equal ['is missing'], res.errors[:basic_pack_id]
      after = interactor.send(:repo).find_actual_count(id)
      after = after.to_h
      refute_equal 20, after[:actual_count_value]
      assert_equal value, after[:actual_count_value]
    end

    def test_delete_actual_count
      id = create_actual_count
      assert_count_changed(:actual_counts, -1) do
        res = interactor.delete_actual_count(id)
        assert res.success, res.message
      end
    end

    private

    def actual_count_attrs
      standard_count_id = create_standard_count
      basic_pack_id = create_basic_pack
      standard_pack_ids = create_standard_pack
      size_reference_ids = create_size_reference

      {
        id: 1,
        standard_count_id: standard_count_id,
        basic_pack_id: basic_pack_id,
        actual_count_value: 1,
        standard_pack_ids: [standard_pack_ids],
        size_reference_ids: [size_reference_ids],
        standard_count: 'ABC',
        basic_pack_code: 'ABC',
        standard_packs: 'ABC',
        size_references: 'ABC',
        active: true
      }
    end

    def fake_actual_count(overrides = {})
      ActualCount.new(actual_count_attrs.merge(overrides))
    end

    def interactor
      @interactor ||= FruitSizeInteractor.new(current_user, {}, {}, {})
    end
  end
end
