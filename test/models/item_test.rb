require "test_helper"

class ItemTest < ActiveSupport::TestCase
  setup { @inventory = inventories(:laptops) }

  test "new item gets the next sequence id" do
    item = @inventory.items.create!(user: users(:owner))
    assert_equal "PART-0002", item.custom_id
  end

  test "edited id must follow the current format" do
    item = items(:dell)
    item.custom_id = "WRONG"
    assert_not item.valid?
  end

  test "id is unique inside the inventory" do
    item = @inventory.items.new(user: users(:owner), custom_id: "PART-0001")
    assert_not item.valid?
  end

  test "database rejects a duplicate id even without validations" do
    item = @inventory.items.new(user: users(:owner), custom_id: "PART-0001", sequence_number: 5)
    assert_raises(ActiveRecord::RecordNotUnique) { item.save!(validate: false) }
  end

  test "full-text search finds items by field values" do
    assert_includes Item.search("del"), items(:dell)
  end
end
