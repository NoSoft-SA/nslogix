# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestTreatmentTypeInteractor < MiniTestWithHooks
    include FruitFactory

    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(MasterfilesApp::FruitRepo)
    end

    def test_treatment_type
      MasterfilesApp::FruitRepo.any_instance.stubs(:find_treatment_type).returns(fake_treatment_type)
      entity = interactor.send(:treatment_type, 1)
      assert entity.is_a?(TreatmentType)
    end

    def test_create_treatment_type
      attrs = fake_treatment_type.to_h.reject { |k, _| k == :id }
      res = interactor.create_treatment_type(attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(TreatmentType, res.instance)
      assert res.instance.id.nonzero?
    end

    def test_create_treatment_type_fail
      attrs = fake_treatment_type(treatment_type_code: nil).to_h.reject { |k, _| k == :id }
      res = interactor.create_treatment_type(attrs)
      refute res.success, 'should fail validation'
      assert_equal ['must be filled'], res.errors[:treatment_type_code]
    end

    def test_update_treatment_type
      id = create_treatment_type
      attrs = interactor.send(:repo).find_hash(:treatment_types, id).reject { |k, _| k == :id }
      value = attrs[:treatment_type_code]
      attrs[:treatment_type_code] = 'a_change'
      res = interactor.update_treatment_type(id, attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(TreatmentType, res.instance)
      assert_equal 'a_change', res.instance.treatment_type_code
      refute_equal value, res.instance.treatment_type_code
    end

    def test_update_treatment_type_fail
      id = create_treatment_type
      attrs = interactor.send(:repo).find_hash(:treatment_types, id).reject { |k, _| %i[id treatment_type_code].include?(k) }
      value = attrs[:description]
      attrs[:description] = 'a_change'
      res = interactor.update_treatment_type(id, attrs)
      refute res.success, "#{res.message} : #{res.errors.inspect}"
      assert_equal ['is missing'], res.errors[:treatment_type_code]
      after = interactor.send(:repo).find_hash(:treatment_types, id)
      refute_equal 'a_change', after[:description]
      assert_equal value, after[:description]
    end

    def test_delete_treatment_type
      id = create_treatment_type
      assert_count_changed(:treatment_types, -1) do
        res = interactor.delete_treatment_type(id)
        assert res.success, res.message
      end
    end

    private

    def treatment_type_attrs
      {
        id: 1,
        treatment_type_code: Faker::Lorem.unique.word,
        description: 'ABC',
        active: true
      }
    end

    def fake_treatment_type(overrides = {})
      TreatmentType.new(treatment_type_attrs.merge(overrides))
    end

    def interactor
      @interactor ||= TreatmentTypeInteractor.new(current_user, {}, {}, {})
    end
  end
end
