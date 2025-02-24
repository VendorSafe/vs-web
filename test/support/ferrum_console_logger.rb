class FerrumConsoleLogger
  attr_reader :logs

  def initialize
    @logs = []
  end

  def puts(log_entry)
    # Ferrum passes log entries as strings, not hashes
    message = log_entry.to_s
    level = "info"
    timestamp = Time.current.to_i

    # Try to parse level from common browser console formats
    if message.start_with?("[ERROR]") || message.downcase.include?("error")
      level = "error"
    elsif message.start_with?("[WARN]") || message.downcase.include?("warning")
      level = "warning"
    end

    @logs << OpenStruct.new(
      message: message,
      level: level,
      timestamp: timestamp
    )
  end

  def clear
    @logs = []
  end
end
