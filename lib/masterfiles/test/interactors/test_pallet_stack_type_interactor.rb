# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestPalletStackTypeInteractor < MiniTestWithHooks
    include PackagingFactory

    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(MasterfilesApp::PackagingRepo)
    end

    def test_pallet_stack_type
      MasterfilesApp::PackagingRepo.any_instance.stubs(:find_pallet_stack_type).returns(fake_pallet_stack_type)
      entity = interactor.send(:pallet_stack_type, 1)
      assert entity.is_a?(PalletStackType)
    end

    def test_create_pallet_stack_type
      attrs = fake_pallet_stack_type.to_h.reject { |k, _| k == :id }
      res = interactor.create_pallet_stack_type(attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(PalletStackType, res.instance)
      assert res.instance.id.nonzero?
    end

    def test_create_pallet_stack_type_fail
      attrs = fake_pallet_stack_type(stack_type_code: nil).to_h.reject { |k, _| k == :id }
      res = interactor.create_pallet_stack_type(attrs)
      refute res.success, 'should fail validation'
      assert_equal ['must be filled'], res.errors[:stack_type_code]
    end

    def test_update_pallet_stack_type
      id = create_pallet_stack_type
      attrs = interactor.send(:repo).find_hash(:pallet_stack_types, id).reject { |k, _| k == :id }
      value = attrs[:stack_type_code]
      attrs[:stack_type_code] = 'a_change'
      res = interactor.update_pallet_stack_type(id, attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(PalletStackType, res.instance)
      assert_equal 'a_change', res.instance.stack_type_code
      refute_equal value, res.instance.stack_type_code
    end

    def test_update_pallet_stack_type_fail
      id = create_pallet_stack_type
      attrs = interactor.send(:repo).find_hash(:pallet_stack_types, id).reject { |k, _| %i[id stack_type_code].include?(k) }
      value = attrs[:description]
      attrs[:description] = 'a_change'
      res = interactor.update_pallet_stack_type(id, attrs)
      refute res.success, "#{res.message} : #{res.errors.inspect}"
      assert_equal ['is missing'], res.errors[:stack_type_code]
      after = interactor.send(:repo).find_hash(:pallet_stack_types, id)
      refute_equal 'a_change', after[:description]
      assert_equal value, after[:description]
    end

    def test_delete_pallet_stack_type
      id = create_pallet_stack_type
      assert_count_changed(:pallet_stack_types, -1) do
        res = interactor.delete_pallet_stack_type(id)
        assert res.success, res.message
      end
    end

    private

    def pallet_stack_type_attrs
      {
        id: 1,
        stack_type_code: Faker::Lorem.unique.word,
        description: 'ABC',
        stack_height: 1,
        active: true
      }
    end

    def fake_pallet_stack_type(overrides = {})
      PalletStackType.new(pallet_stack_type_attrs.merge(overrides))
    end

    def interactor
      @interactor ||= PalletStackTypeInteractor.new(current_user, {}, {}, {})
    end
  end
end
