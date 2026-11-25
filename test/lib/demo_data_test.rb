require "test_helper"

class DemoDataTest < ActiveSupport::TestCase
  test "does nothing when inventories already exist" do
    assert_no_difference([ "Inventory.count", "Item.count", "Comment.count" ]) { DemoData.seed! }
  end

  test "fills an empty database" do
    Inventory.destroy_all
    DemoData.seed!
    assert_equal [ "Company Computers", "Library", "Parts" ], Inventory.order(:title).pluck(:title)
    assert_equal 9, Item.count
  end
end
