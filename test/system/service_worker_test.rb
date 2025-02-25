require 'application_system_test_case'

class ServiceWorkerTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  def setup
    # Configure headless mode based on environment variable
    Capybara.javascript_driver = ENV['OPEN_BROWSER'] ? :selenium_chrome : :selenium_chrome_headless

    # Create test data
    @team = create(:team)
    @user = create(:user)
    @membership = create(:membership, user: @user, team: @team)

    # Create a training program with content
    @program = create(:training_program,
                      team: @team,
                      name: 'Service Worker Test Program',
                      state: 'published')

    # Create content
    @video_content = create(:training_content,
                            training_program: @program,
                            title: 'Video Module',
                            content_type: 'video',
                            sort_order: 1)

    @document_content = create(:training_content,
                               training_program: @program,
                               title: 'Document Module',
                               content_type: 'document',
                               body: 'Test document content',
                               sort_order: 2)

    sign_in @user
  end

  test 'service worker registration' do
    # Ensure service worker file exists
    assert File.exist?(Rails.public_path.join('service-worker.js')),
           'Service worker file should exist in public directory'

    # Visit the training player page
    visit account_team_training_program_player_path(@team, @program)

    # Check if service worker is registered
    registered = page.evaluate_script(<<~JS)
      'serviceWorker' in navigator &&#{' '}
      navigator.serviceWorker.controller !== null
    JS

    assert registered, 'Service worker should be registered'
  end

  test 'offline page is served when offline' do
    # Ensure offline page exists
    assert File.exist?(Rails.public_path.join('offline.html')),
           'Offline HTML file should exist in public directory'

    # Visit the training player page
    visit account_team_training_program_player_path(@team, @program)

    # Simulate going offline and requesting a new page
    page.execute_script(<<~JS)
      // Simulate offline mode
      window.navigator.onLine = false;
      window.dispatchEvent(new Event('offline'));

      // Force fetch to fail with a network error
      const originalFetch = window.fetch;
      window.fetch = function(url, options) {
        if (url !== '/offline.html') {
          return Promise.reject(new Error('Network error'));
        }
        return originalFetch(url, options);
      };
    JS

    # Try to navigate to a different page
    visit account_team_path(@team)

    # Should show offline page content
    assert_text "You're Offline"
    assert_text "Don't worry - any progress you've made in your training has been saved locally"
  end

  test 'caching of training program data' do
    # Visit the training player page to cache the content
    visit account_team_training_program_player_path(@team, @program)

    # Complete a module to ensure progress is tracked
    page.execute_script("document.querySelector('video').dispatchEvent(new Event('ended'))")

    # Wait for progress to be saved
    assert_selector '.module-button.complete', text: 'Video Module'

    # Simulate going offline
    page.execute_script(<<~JS)
      window.navigator.onLine = false;
      window.dispatchEvent(new Event('offline'));
    JS

    # Reload the page
    visit account_team_training_program_player_path(@team, @program)

    # Should still show the training program content from cache
    assert_text @program.name
    assert_selector '.module-button', text: 'Video Module'
    assert_selector '.module-button', text: 'Document Module'

    # Should still show completed status from cache
    assert_selector '.module-button.complete', text: 'Video Module'
  end

  test 'background sync when coming back online' do
    # Visit the training player page
    visit account_team_training_program_player_path(@team, @program)

    # Simulate going offline
    page.execute_script(<<~JS)
      window.navigator.onLine = false;
      window.dispatchEvent(new Event('offline'));
    JS

    # Complete a module while offline
    page.execute_script("document.querySelector('video').dispatchEvent(new Event('ended'))")

    # Should mark as complete in UI
    assert_selector '.module-button.complete', text: 'Video Module'

    # Simulate going back online
    page.execute_script(<<~JS)
      window.navigator.onLine = true;
      window.dispatchEvent(new Event('online'));
    JS

    # Should show syncing indicator
    assert_text 'Syncing changes'

    # Should still show module as complete after sync
    assert_selector '.module-button.complete', text: 'Video Module'
  end
end
