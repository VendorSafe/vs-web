# Configure system tests to support both headless and browser modes
Rails.application.config.before_configuration do
  # Default to headless mode unless OPEN_BROWSER is set
  headless_mode = !ENV["OPEN_BROWSER"]

  # Configure Capybara for system tests
  Capybara.register_driver :selenium_chrome_configurable do |app|
    options = Selenium::WebDriver::Chrome::Options.new

    if headless_mode
      options.add_argument("--headless")
      options.add_argument("--disable-gpu")
    end

    # Common options for both modes
    options.add_argument("--no-sandbox")
    options.add_argument("--window-size=1400,1400")
    options.add_argument("--disable-dev-shm-usage")

    # Enable downloads in headless mode
    if headless_mode
      options.add_preference(
        "download.default_directory",
        Rails.root.join("tmp/downloads").to_s
      )
    end

    # Enable debugging if requested
    if ENV["CHROME_DEBUG"]
      options.add_argument("--auto-open-devtools-for-tabs")
      options.add_argument("--remote-debugging-port=9222")
    end

    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      options: options
    )
  end

  # Set up test directories
  Rails.application.config.after_initialize do
    # Create downloads directory for headless testing
    FileUtils.mkdir_p(Rails.root.join("tmp/downloads"))

    # Create fixtures directory for test files
    FileUtils.mkdir_p(Rails.root.join("test/fixtures/files"))

    # Create a sample video file for tests if it doesn't exist
    sample_video_path = Rails.root.join("test/fixtures/files/sample.mp4")
    unless File.exist?(sample_video_path)
      FileUtils.cp(
        Rails.root.join("test/fixtures/files/sample.mp4.example"),
        sample_video_path
      )
    end
  end

  # Configure Capybara
  Capybara.configure do |config|
    config.server = :puma, {Silent: true}
    config.default_max_wait_time = 5
    config.default_driver = :selenium_chrome_configurable
    config.javascript_driver = :selenium_chrome_configurable

    # Use rack_test for non-JavaScript tests
    config.default_driver = :rack_test
  end

  # Configure test screenshots
  Rails.application.config.action_dispatch.system_test_screenshots = !headless_mode

  # Helper method to toggle browser mode
  def self.toggle_browser_mode(open_browser)
    ENV["OPEN_BROWSER"] = open_browser ? "1" : nil
    Capybara.current_driver = Capybara.javascript_driver
  end
end
