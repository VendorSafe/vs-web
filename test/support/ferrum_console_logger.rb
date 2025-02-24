class FerrumConsoleLogger
  attr_reader :logs

  def initialize
    @logs = []
  end

  def puts(log_params)
    message = log_params[:message]
    level = log_params[:level]
    timestamp = log_params[:timestamp]
    @logs << OpenStruct.new(message: message, level: level, timestamp: timestamp)
  end

  def clear
    @logs = []
  end
end
