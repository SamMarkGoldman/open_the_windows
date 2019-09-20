require 'time'

module Delivery
  class Scheduler
    FILE_NAME = Config::Delivery::SENT_HISTORY_FILE
    SECONDS_IN_DAY = (24 * 60 * 60.0)

    def initialize(inside, outside)
      @inside = inside
      @outside = outside
    end

    def schedule
      # puts(content) if !recent_message?
      Email.new.deliver(content) if !recent_message?
      update
    end

    def recent_message?
      return false unless File.file?(FILE_NAME)
      Time.now - Time.parse(File.read(FILE_NAME)) < SECONDS_IN_DAY
    end

    def update
      File.write(FILE_NAME, Time.now)
    end

    def content
      %{Open the damn windows!\n\nIt's #{@inside} inside, but it's #{@outside} outside.}
    end
  end
end