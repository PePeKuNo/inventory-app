require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "ADMIN_EMAIL becomes admin on sign up" do
    ENV["ADMIN_EMAIL"] = "boss@example.com"
    assert User.create!(name: "Boss", email: "Boss@example.com", password: "password").admin?
    assert_not User.create!(name: "Other", email: "other@example.com", password: "password").admin?
  ensure
    ENV.delete("ADMIN_EMAIL")
  end
end
