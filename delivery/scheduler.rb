require 'time'

module Delivery
  class Scheduler
    FILE_NAME = "#{Config::ROOT_DIR}/#{Config::Delivery::SENT_HISTORY_FILE}"
    DAYS = {
      0 => :sunday,
      1 => :monday,
      2 => :tuesday,
      3 => :wednesday,
      4 => :thursday,
      5 => :friday,
      6 => :saturday
    }

    def initialize(inside, outside)
      @inside = inside
      @outside = outside
    end

    def schedule
      if !message_sent_today? && in_whitelist_time? && prediction_pleasant?
        Email.new.deliver(content)
        update
      end
    end

    def message_sent_today?
      return false unless File.file?(FILE_NAME)

      now = Time.now
      sent = Time.parse(File.read(FILE_NAME))
      now.year === sent.year &&
        now.month === sent.month &&
        now.day === sent.day
    end

    def in_whitelist_time?
      time = Time.now
      day = DAYS[time.wday]
      whitelist_window = Config::Delivery::SCHEDULE_WHITELIST[day]
      time >= Time.parse(whitelist_window.first) && time <= Time.parse(whitelist_window.last)
    end

    def prediction_pleasant?
      prediction = Temp::Analyzer.future_prediction
      Temp::Analyzer.within_pleasant_range?(prediction)
    end

    def update
      File.write(FILE_NAME, Time.now)
    end

    def content
      %{Open the damn windows!\n\nIt's #{@inside} inside, but it's #{@outside} outside.}
    end
  end
end