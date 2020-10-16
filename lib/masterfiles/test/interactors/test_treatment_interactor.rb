# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestTreatmentInteractor < MiniTestWithHooks
    include FruitFactory

    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(MasterfilesApp::FruitRepo)
    end

    def test_treatment
      MasterfilesApp::FruitRepo.any_instance.stubs(:find_treatment).returns(fake_treatment)
      entity = interactor.send(:treatment, 1)
      assert entity.is_a?(Treatment)
    end

    def test_create_treatment
      attrs = fake_treatment.to_h.reject { |k, _| k == :id }
      res = interactor.create_treatment(attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(Treatment, res.instance)
      assert res.instance.id.nonzero?
    end

    def test_create_treatment_fail
      attrs = fake_treatment(treatment_code: nil).to_h.reject { |k, _| k == :id }
      res = interactor.create_treatment(attrs)
      refute res.success, 'should fail validation'
      assert_equal ['must be filled'], res.errors[:treatment_code]
    end

    def test_update_treatment
      id = create_treatment
      attrs = interactor.send(:repo).find_hash(:treatments, id).reject { |k, _| k == :id }
      value = attrs[:treatment_code]
      attrs[:treatment_code] = 'a_change'
      res = interactor.update_treatment(id, attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(Treatment, res.instance)
      assert_equal 'a_change', res.instance.treatment_code
      refute_equal value, res.instance.treatment_code
    end

    def test_update_treatment_fail
      id = create_treatment
      attrs = interactor.send(:repo).find_hash(:treatments, id).reject { |k, _| %i[id treatment_code].include?(k) }
      value = attrs[:description]
      attrs[:description] = 'a_change'
      res = interactor.update_treatment(id, attrs)
      refute res.success, "#{res.message} : #{res.errors.inspect}"
      assert_equal ['is missing'], res.errors[:treatment_code]
      after = interactor.send(:repo).find_hash(:treatments, id)
      refute_equal 'a_change', after[:description]
      assert_equal value, after[:description]
    end

    def test_delete_treatment
      id = create_treatment
      assert_count_changed(:treatments, -1) do
        res = interactor.delete_treatment(id)
        assert res.success, res.message
      end
    end

    private

    def treatment_attrs
      treatment_type_id = create_treatment_type

      {
        id: 1,
        treatment_type_id: treatment_type_id,
        treatment_code: Faker::Lorem.unique.word,
        description: 'ABC',
        active: true,
        treatment_type_code: 'ABC'
      }
    end

    def fake_treatment(overrides = {})
      Treatment.new(treatment_attrs.merge(overrides))
    end

    def interactor
      @interactor ||= TreatmentInteractor.new(current_user, {}, {}, {})
    end
  end
end
