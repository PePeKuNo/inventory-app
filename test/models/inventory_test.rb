require "test_helper"

class InventoryTest < ActiveSupport::TestCase
  setup { @inventory = inventories(:laptops) }

  test "access rules" do
    assert @inventory.editable_by?(users(:owner))
    assert @inventory.editable_by?(users(:admin))
    assert_not @inventory.editable_by?(users(:writer))

    assert @inventory.writable_by?(users(:writer))
    assert_not @inventory.writable_by?(users(:stranger))
    assert_not @inventory.writable_by?(nil)

    @inventory.is_public = true
    assert @inventory.writable_by?(users(:stranger))
  end

  test "custom fields come in the owner's order" do
    @inventory.update!(custom_int1_position: 0, custom_string1_position: 1)
    assert_equal %w[Price Model], @inventory.custom_fields.map(&:name)
    assert_equal %w[Model], @inventory.table_fields.map(&:name)
  end

  test "enabled field needs a name" do
    @inventory.custom_bool1_state = true
    assert_not @inventory.valid?
  end

  test "tag list creates tags once" do
    @inventory.update!(tag_list: "Office, IT, office")
    assert_equal %w[it office], @inventory.tags.pluck(:name).sort
  end

  test "optimistic locking rejects a stale save" do
    other_copy = Inventory.find(@inventory.id)
    @inventory.update!(title: "First")
    assert_raises(ActiveRecord::StaleObjectError) { other_copy.update!(title: "Second") }
  end

  test "statistics are aggregated" do
    stats = @inventory.statistics
    assert_equal 1, stats["items_count"]
    assert_equal 1000, stats["custom_int1_avg"]
    assert_equal "Dell", stats["custom_string1_mode"]
  end
end
