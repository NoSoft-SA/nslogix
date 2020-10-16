# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestMarkPermission < Minitest::Test
    include Crossbeams::Responses

    def entity(attrs = {})
      base_attrs = {
        id: 1,
        mark_code: Faker::Lorem.unique.word,
        description: 'ABC',
        active: true
      }
      MasterfilesApp::Mark.new(base_attrs.merge(attrs))
    end

    def test_create
      res = MasterfilesApp::TaskPermissionCheck::Mark.call(:create)
      assert res.success, 'Should always be able to create a mark'
    end

    def test_edit
      MasterfilesApp::MarketingRepo.any_instance.stubs(:find_mark).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::Mark.call(:edit, 1)
      assert res.success, 'Should be able to edit a mark'
    end

    def test_delete
      MasterfilesApp::MarketingRepo.any_instance.stubs(:find_mark).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::Mark.call(:delete, 1)
      assert res.success, 'Should be able to delete a mark'
    end
  end
end
