# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestSeasonGroupPermission < Minitest::Test
    include Crossbeams::Responses

    def entity(attrs = {})
      base_attrs = {
        id: 1,
        season_group_code: 'ABC',
        description: 'ABC',
        season_group_year: 1,
        active: true
      }
      MasterfilesApp::SeasonGroup.new(base_attrs.merge(attrs))
    end

    def test_create
      res = MasterfilesApp::TaskPermissionCheck::SeasonGroup.call(:create)
      assert res.success, 'Should always be able to create a season_group'
    end

    def test_edit
      MasterfilesApp::CalendarRepo.any_instance.stubs(:find_season_group).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::SeasonGroup.call(:edit, 1)
      assert res.success, 'Should be able to edit a season_group'
    end

    def test_delete
      MasterfilesApp::CalendarRepo.any_instance.stubs(:find_season_group).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::SeasonGroup.call(:delete, 1)
      assert res.success, 'Should be able to delete a season_group'
    end
  end
end
