# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestStandardPackInteractor < MiniTestWithHooks
    include GeneralFactory
    include FruitFactory

    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(MasterfilesApp::FruitSizeRepo)
    end

    def test_standard_pack
      MasterfilesApp::FruitSizeRepo.any_instance.stubs(:find_standard_pack_flat).returns(fake_standard_pack)
      entity = interactor.send(:standard_pack, 1)
      assert entity.is_a?(StandardPackFlat)
    end

    def test_create_standard_pack
      attrs = fake_standard_pack.to_h.reject { |k, _| k == :id }
      res = interactor.create_standard_pack(attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(StandardPackFlat, res.instance)
      assert res.instance.id.nonzero?
    end

    def test_create_standard_pack_fail
      attrs = fake_standard_pack(standard_pack_code: nil).to_h.reject { |k, _| k == :id }
      res = interactor.create_standard_pack(attrs)
      refute res.success, 'should fail validation'
      assert_equal ['must be filled'], res.errors[:standard_pack_code]
    end

    def test_update_standard_pack
      id = create_standard_pack
      attrs = interactor.send(:repo).find_hash(:standard_packs, id).reject { |k, _| k == :id }
      value = attrs[:standard_pack_code]
      attrs[:standard_pack_code] = 'a_change'
      res = interactor.update_standard_pack(id, attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(StandardPackFlat, res.instance)
      assert_equal 'a_change', res.instance.standard_pack_code
      refute_equal value, res.instance.standard_pack_code
    end

    def test_update_standard_pack_fail
      id = create_standard_pack
      attrs = interactor.send(:repo).find_hash(:standard_packs, id)
      attrs.delete(:standard_pack_code)
      value = attrs[:description]
      attrs[:id] = 'a change'
      res = interactor.update_standard_pack(id, attrs)
      refute res.success, "#{res.message} : #{res.errors.inspect}"
      assert_equal ['is missing'], res.errors[:standard_pack_code]
      after = interactor.send(:repo).find_hash(:standard_packs, id)
      refute_equal 'a change', after[:description]
      assert_equal value, after[:description]
    end

    def test_delete_standard_pack
      id = create_standard_pack
      assert_count_changed(:standard_packs, -1) do
        res = interactor.delete_standard_pack(id)
        assert res.success, res.message
      end
    end

    private

    def standard_pack_attrs
      basic_pack_id = create_basic_pack
      {
        id: 1,
        standard_pack_code: Faker::Lorem.unique.word,
        description: 'ABC',
        standard_pack_label: 'ABC',
        active: true,
        material_mass: 1.0,
        basic_pack_id: basic_pack_id,
        basic_pack_code: 'ABC',
        use_size_ref_for_edi: false,
        bin: false,
        container_type: nil,
        material_type: nil
      }
    end

    def fake_standard_pack(overrides = {})
      StandardPackFlat.new(standard_pack_attrs.merge(overrides))
    end

    def interactor
      @interactor ||= StandardPackInteractor.new(current_user, {}, {}, {})
    end
  end
end
