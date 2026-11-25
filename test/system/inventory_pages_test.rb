require "application_system_test_case"

# Browser tests for the parts that need JavaScript (Stimulus controllers).
class InventoryPagesTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @inventory = inventories(:laptops)
    sign_in users(:owner)
  end

  test "custom ID tab shows a live preview from the server" do
    visit inventory_path(@inventory, tab: "custom_id")
    assert_selector "[data-custom-id-target=preview]", text: "PART-0002"

    click_on "Add element"
    all(".format-input").last.fill_in with: "-X"
    assert_selector "[data-custom-id-target=preview]", text: "PART-0002-X"
  end

  test "table toolbar is enabled only when a row is selected" do
    visit inventory_path(@inventory)
    delete_button = find("button[form=items-form]")
    assert delete_button.disabled?

    first("input[name='ids[]']").check
    assert_not delete_button.disabled?
  end
end
