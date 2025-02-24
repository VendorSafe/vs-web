module Waiting
  def wait_for_condition(timeout: Capybara.default_max_wait_time)
    Timeout.timeout(timeout) do
      sleep(0.1) until yield
    end
  end

  def wait_for_ajax
    wait_for_condition { finished_all_ajax_requests? }
  end

  def wait_for_animations
    wait_for_condition { page.evaluate_script('jQuery(:animated).length') == 0 }
  end

  def wait_for_turbo
    wait_for_condition { page.evaluate_script('!!window.Turbo && !window.Turbo.navigator.currentVisit') }
  end

  private

  def finished_all_ajax_requests?
    return true unless page.evaluate_script('window.jQuery')
    page.evaluate_script('jQuery.active').zero?
  end
end
