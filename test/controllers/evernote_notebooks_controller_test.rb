require 'test_helper'

class EvernoteNotebooksControllerTest < ActionController::TestCase
  setup do
    @evernote_notebook = evernote_notebooks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:evernote_notebooks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create evernote_notebook" do
    assert_difference('EvernoteNotebook.count') do
      post :create, evernote_notebook: { guid: @evernote_notebook.guid }
    end

    assert_redirected_to evernote_notebook_path(assigns(:evernote_notebook))
  end

  test "should show evernote_notebook" do
    get :show, id: @evernote_notebook
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @evernote_notebook
    assert_response :success
  end

  test "should update evernote_notebook" do
    patch :update, id: @evernote_notebook, evernote_notebook: { guid: @evernote_notebook.guid }
    assert_redirected_to evernote_notebook_path(assigns(:evernote_notebook))
  end

  test "should destroy evernote_notebook" do
    assert_difference('EvernoteNotebook.count', -1) do
      delete :destroy, id: @evernote_notebook
    end

    assert_redirected_to evernote_notebooks_path
  end
end
