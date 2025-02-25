if defined?(Webdrivers)
  # Set a specific version of ChromeDriver
  # Check available versions at: https://chromedriver.storage.googleapis.com/index.html
  Webdrivers::Chromedriver.required_version = "123.0.6312.58" # Use a stable version
  
  # Alternatively, you can use the latest stable version
  # Webdrivers::Chromedriver.update
end 