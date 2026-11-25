require "test_helper"

class PermissionsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @inventory = inventories(:laptops)
    @item = items(:dell)
  end

  test "guests can read but not write" do
    get inventory_path(@inventory)
    assert_response :success
    get inventory_item_path(@inventory, @item)
    assert_response :success

    post inventory_items_path(@inventory), params: { item: { custom_string1: "HP" } }
    assert_redirected_to new_user_session_path
  end

  test "writer can add items but cannot change inventory settings" do
    sign_in users(:writer)
    assert_difference("Item.count") do
      post inventory_items_path(@inventory), params: { item: { custom_string1: "HP" } }
    end

    patch inventory_path(@inventory), params: { inventory: { title: "Hacked" } }
    assert_equal "Laptops", @inventory.reload.title
  end

  test "stranger cannot add items to a private inventory" do
    sign_in users(:stranger)
    assert_no_difference("Item.count") do
      post inventory_items_path(@inventory), params: { item: { custom_string1: "HP" } }
    end
  end

  test "autosave returns the new lock version and 409 for a stale one" do
    sign_in users(:owner)
    patch inventory_path(@inventory, format: :json), params: { inventory: { title: "New", lock_version: 0 } }
    assert_response :success
    assert_equal 1, response.parsed_body["lock_version"]

    patch inventory_path(@inventory, format: :json), params: { inventory: { title: "Old", lock_version: 0 } }
    assert_response :conflict
    assert_equal "New", @inventory.reload.title
  end

  test "stale item edit is rejected" do
    sign_in users(:owner)
    @item.update!(custom_string1: "Changed by someone")
    patch inventory_item_path(@inventory, @item), params: { item: { custom_string1: "Mine", lock_version: 0 } }
    assert_response :conflict
    assert_equal "Changed by someone", @item.reload.custom_string1
  end

  test "one like per user" do
    sign_in users(:stranger)
    post inventory_item_like_path(@inventory, @item)
    post inventory_item_like_path(@inventory, @item)
    assert_equal 1, @item.reload.likes_count
  end

  test "admin can remove own admin role" do
    admin = users(:admin)
    sign_in admin
    patch bulk_update_admin_users_path, params: { operation: "remove_admin", ids: [ admin.id ] }
    assert_redirected_to root_path
    assert_not admin.reload.admin?
  end

  # Devise checks active_for_authentication? on every request, so blocking works immediately.
  test "blocked user is signed out" do
    user = users(:stranger)
    sign_in user
    user.update!(blocked: true)
    get new_inventory_path
    assert_redirected_to new_user_session_path
  end

  test "privacy policy page is public" do
    get privacy_path
    assert_response :success
  end
end
