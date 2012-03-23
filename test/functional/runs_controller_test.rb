require 'test_helper'

class RunsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Run.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Run.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Run.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to run_url(assigns(:run))
  end

  def test_edit
    get :edit, :id => Run.first
    assert_template 'edit'
  end

  def test_update_invalid
    Run.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Run.first
    assert_template 'edit'
  end

  def test_update_valid
    Run.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Run.first
    assert_redirected_to run_url(assigns(:run))
  end

  def test_destroy
    run = Run.first
    delete :destroy, :id => run
    assert_redirected_to runs_url
    assert !Run.exists?(run.id)
  end
end
