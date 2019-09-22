require 'time'

module Delivery
  class Scheduler
    FILE_NAME = "#{Config::ROOT_DIR}/#{Config::Delivery::SENT_HISTORY_FILE}"
    SECONDS_IN_DAY = (24 * 60 * 60.0)
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
      # puts(content) if !recent_message?
      if !recent_message? && in_whitelist_time?
        Email.new.deliver(content)
        update
      end
    end

    def recent_message?
      return false unless File.file?(FILE_NAME)
      Time.now - Time.parse(File.read(FILE_NAME)) < SECONDS_IN_DAY
    end

    def in_whitelist_time?
      time = Time.now
      day = DAYS[time.wday]
      whitelist_window = Config::Delivery::SCHEDULE_WHITELIST[day]
      time >= Time.parse(whitelist_window.first) && time <= Time.parse(whitelist_window.last)
    end

    def update
      File.write(FILE_NAME, Time.now)
    end

    def content
      %{Open the damn windows!\n\nIt's #{@inside} inside, but it's #{@outside} outside.}
    end
  end
end