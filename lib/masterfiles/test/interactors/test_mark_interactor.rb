# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestMarkInteractor < MiniTestWithHooks
    include MarketingFactory

    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(MasterfilesApp::MarketingRepo)
    end

    def test_mark
      MasterfilesApp::MarketingRepo.any_instance.stubs(:find_mark).returns(fake_mark)
      entity = interactor.send(:mark, 1)
      assert entity.is_a?(Mark)
    end

    def test_create_mark
      attrs = fake_mark.to_h.reject { |k, _| k == :id }
      res = interactor.create_mark(attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(Mark, res.instance)
      assert res.instance.id.nonzero?
    end

    def test_create_mark_fail
      attrs = fake_mark(mark_code: nil).to_h.reject { |k, _| k == :id }
      res = interactor.create_mark(attrs)
      refute res.success, 'should fail validation'
      assert_equal ['must be filled'], res.errors[:mark_code]
    end

    def test_update_mark
      id = create_mark
      attrs = interactor.send(:repo).find_hash(:marks, id).reject { |k, _| k == :id }
      value = attrs[:mark_code]
      attrs[:mark_code] = 'a_change'
      res = interactor.update_mark(id, attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(Mark, res.instance)
      assert_equal 'a_change', res.instance.mark_code
      refute_equal value, res.instance.mark_code
    end

    def test_update_mark_fail
      id = create_mark
      attrs = interactor.send(:repo).find_hash(:marks, id).reject { |k, _| %i[id mark_code].include?(k) }
      value = attrs[:description]
      attrs[:description] = 'a_change'
      res = interactor.update_mark(id, attrs)
      refute res.success, "#{res.message} : #{res.errors.inspect}"
      assert_equal ['is missing'], res.errors[:mark_code]
      after = interactor.send(:repo).find_hash(:marks, id)
      refute_equal 'a_change', after[:description]
      assert_equal value, after[:description]
    end

    def test_delete_mark
      id = create_mark
      assert_count_changed(:marks, -1) do
        res = interactor.delete_mark(id)
        assert res.success, res.message
      end
    end

    private

    def mark_attrs
      {
        id: 1,
        mark_code: Faker::Lorem.unique.word,
        description: 'ABC',
        active: true
      }
    end

    def fake_mark(overrides = {})
      Mark.new(mark_attrs.merge(overrides))
    end

    def interactor
      @interactor ||= MarkInteractor.new(current_user, {}, {}, {})
    end
  end
end
