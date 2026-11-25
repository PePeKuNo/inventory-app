require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Cuprite drives Chrome directly over CDP (no Selenium / chromedriver).
  driven_by :cuprite, screen_size: [ 1400, 1000 ], options: { process_timeout: 20, js_errors: true }
end
