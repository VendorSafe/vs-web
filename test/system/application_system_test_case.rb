require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Use Cuprite for JS-enabled tests with zsh as the shell
  driven_by :cuprite, options: {
    window_size: [1400, 1400],
    browser_options: { 'no-sandbox': nil },
    headless: !ENV['OPEN_BROWSER'],
    env: { 'SHELL' => '/bin/zsh' } # Set zsh as the shell
  }

  # This allows system commands executed during tests to use zsh
  setup do
    ENV['SHELL'] = '/bin/zsh'
  end
end
