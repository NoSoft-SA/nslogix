# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestPmBomsProductRoutes < RouteTester

  INTERACTOR = MasterfilesApp::PmBomsProductInteractor

  def test_edit
    authorise_pass! permission_check: MasterfilesApp::TaskPermissionCheck::PmBomsProduct
    ensure_exists!(INTERACTOR)
    Masterfiles::Packaging::PmBomsProduct::Edit.stub(:call, bland_page) do
      get 'masterfiles/packaging/pm_boms_products/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'masterfiles/packaging/pm_boms_products/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_show
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Masterfiles::Packaging::PmBomsProduct::Show.stub(:call, bland_page) do
      get 'masterfiles/packaging/pm_boms_products/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'masterfiles/packaging/pm_boms_products/1', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    INTERACTOR.any_instance.stubs(:update_pm_boms_product).returns(ok_response(instance: row_vals))
    patch_as_fetch 'masterfiles/packaging/pm_boms_products/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_update_grid
  end

  def test_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:update_pm_boms_product).returns(bad_response)
    Masterfiles::Packaging::PmBomsProduct::Edit.stub(:call, bland_page) do
      patch_as_fetch 'masterfiles/packaging/pm_boms_products/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    authorise_pass! permission_check: MasterfilesApp::TaskPermissionCheck::PmBomsProduct
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:delete_pm_boms_product).returns(ok_response)
    delete_as_fetch 'masterfiles/packaging/pm_boms_products/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_delete_from_grid
  end

  def test_delete_fail
    authorise_pass! permission_check: MasterfilesApp::TaskPermissionCheck::PmBomsProduct
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:delete_pm_boms_product).returns(bad_response)
    delete_as_fetch 'masterfiles/packaging/pm_boms_products/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_error
  end

  def test_new
    authorise_pass!
    ensure_exists!(MasterfilesApp::PmBomInteractor)
    Masterfiles::Packaging::PmBomsProduct::New.stub(:call, bland_page) do
      get  'masterfiles/packaging/pm_boms/1/pm_boms_products/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    ensure_exists!(MasterfilesApp::PmBomInteractor)
    get 'masterfiles/packaging/pm_boms/1/pm_boms_products/new', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_create_remotely
    authorise_pass!
    ensure_exists!(MasterfilesApp::PmBomInteractor)
    row_vals = Hash.new(1)
    INTERACTOR.any_instance.stubs(:create_pm_boms_product).returns(ok_response(instance: row_vals))
    post_as_fetch '/masterfiles/packaging/pm_boms/1/pm_boms_products/new', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_response
  end

  def test_create_remotely_fail
    authorise_pass!
    ensure_exists!(MasterfilesApp::PmBomInteractor)
    INTERACTOR.any_instance.stubs(:create_pm_boms_product).returns(bad_response)
    Masterfiles::Packaging::PmBomsProduct::New.stub(:call, bland_page) do
      post_as_fetch '/masterfiles/packaging/pm_boms/1/pm_boms_products/new', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_response
  end
end
