module Delivery
  class Scheduler
    FILE_NAME = Config::Delivery::SENT_HISTORY_FILE
    SECONDS_IN_DAY = (24 * 60 * 60.0)

    def initialize(message)
      @initial = message[:initial]
      @final = message[:final]
    end

    def schedule
      # puts(content) if !recent_message?
      Email.new.deliver(content) if !recent_message?
      update
    end

    def recent_message?
      return false unless File.file?(FILE_NAME)
      @final.time - Time.parse(File.read(FILE_NAME)) < SECONDS_IN_DAY
    end

    def update
      File.write(FILE_NAME, @final.time)
    end

    def content
      %{
        #{@initial}
        #{@final}

        Time difference: #{@final.days_diff(@initial).round(2)}
        Pressure difference: #{@final.pressure_diff(@initial).round(2)}
        Slope: #{@final.slope(@initial).round(2)}
      }
    end
  end
end