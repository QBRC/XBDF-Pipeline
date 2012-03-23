require 'test_helper'

class CommandsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Command.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Command.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Command.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to command_url(assigns(:command))
  end

  def test_edit
    get :edit, :id => Command.first
    assert_template 'edit'
  end

  def test_update_invalid
    Command.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Command.first
    assert_template 'edit'
  end

  def test_update_valid
    Command.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Command.first
    assert_redirected_to command_url(assigns(:command))
  end

  def test_destroy
    command = Command.first
    delete :destroy, :id => command
    assert_redirected_to commands_url
    assert !Command.exists?(command.id)
  end
end
