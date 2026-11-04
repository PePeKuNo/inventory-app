require "test_helper"

class CustomIdTest < ActiveSupport::TestCase
  FORMAT = [
    { "type" => "fixed", "format" => "📚-" },
    { "type" => "random20", "format" => "X5_" },
    { "type" => "sequence", "format" => "D3_" },
    { "type" => "datetime", "format" => "yyyy" }
  ].freeze

  test "builds an id like the example from the task" do
    id = CustomId.generate(FORMAT, sequence: 13, time: Time.utc(2025, 5, 1))
    assert_match(/\A📚-[0-9A-F]{5}_013_2025\z/, id)
  end

  test "generated ids match the format regexp" do
    CustomId::TYPES.each do |type|
      elements = [ { "type" => type, "format" => type == "fixed" ? "A-" : "" } ]
      assert_match CustomId.regexp(elements), CustomId.generate(elements, sequence: 7), type
    end
  end

  test "regexp rejects ids in another format" do
    refute_match CustomId.regexp(FORMAT), "BOOK-001"
  end

  test "random6 is zero padded to 6 digits by default" do
    assert_match(/\A\d{6}\z/, CustomId.generate([ { "type" => "random6" } ], sequence: 1))
  end
end
