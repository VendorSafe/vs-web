ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "capybara/rails"

# Use Cuprite for system tests
require "capybara/cuprite"

# Configure headless/browser mode for system tests
HEADLESS_MODE = !ENV["OPEN_BROWSER"]

# Configure Cuprite driver
Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app, {
    window_size: [1400, 1400],
    browser_options: { 'no-sandbox': nil },
    headless: HEADLESS_MODE
  })
end

# Set Cuprite as the default driver
Capybara.javascript_driver = :cuprite
Capybara.default_driver = :cuprite

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include FactoryBot::Syntax::Methods
end

class ActionDispatch::SystemTestCase
  # Make the Capybara DSL available in system tests
  include Capybara::DSL
  include Warden::Test::Helpers

  # Helper methods for training program tests
  def complete_video_module
    # Wait for video to load and simulate completion
    find("video")
    page.execute_script("document.querySelector('video').dispatchEvent(new Event('ended'))")
    wait_for_ajax
  end

  def complete_quiz(correct: true)
    within(".question-list") do
      all(".answer-option").each do |option|
        if correct && option.text.include?("Correct Answer")
          option.click
        elsif !correct && option.text.include?("Wrong Answer")
          option.click
        end
      end
      click_button "Submit Answers"
    end
    wait_for_ajax
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script("jQuery.active").zero?
  end

  def toggle_browser_mode(open_browser)
    ENV["OPEN_BROWSER"] = open_browser ? "1" : nil
    Capybara.current_driver = Capybara.javascript_driver
  end

  # Clean up any resources after each test
  def teardown
    super
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

# Configure VCR for recording HTTP interactions
require "vcr"
VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.allow_http_connections_when_no_cassette = true

  # Allow ChromeDriver downloads
  config.ignore_hosts(
    'chromedriver.storage.googleapis.com',
    'github.com',
    'objects.githubusercontent.com'
  )
end

# Configure test coverage reporting
require "simplecov"
SimpleCov.start "rails" do
  add_filter "/test/"
  add_filter "/config/"

  add_group "Controllers", "app/controllers"
  add_group "Models", "app/models"
  add_group "Components", "app/javascript/components"
  add_group "Stores", "app/javascript/stores"
end

# Load support files
Dir[Rails.root.join("test/support/**/*.rb")].each { |f| require f }

# Configure time helpers
include ActiveSupport::Testing::TimeHelpers

# Configure test screenshots
if ENV["SAVE_SCREENSHOTS"]
  Capybara.save_path = Rails.root.join("tmp/screenshots")
end
