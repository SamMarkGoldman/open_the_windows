require 'pry'
require 'date'
require_relative 'config'
require_relative 'delivery'
require_relative 'temp'


inside_thermometer = Temp::Reader.new(Config::Temp::Devices::INSIDE)
outside_thermometer = Temp::Reader.new(Config::Temp::Devices::OUTSIDE)
outside_temp = outside_thermometer.read
inside_temp = inside_thermometer.read

# log data
puts "inside: #{inside_temp}\noutside: #{outside_temp}"
Temp::Storage.new.append_current_reading(inside_temp, outside_temp)

if !Temp::Analyzer.within_pleasant_range?(outside_temp)
  puts 'Outside temperature is not within pleasant range.'
  exit 0
end

if !Temp::Analyzer.outside_more_pleasant?(inside_temp, outside_temp)
  puts 'Outside temperature is less pleasant than inside.'
  exit 0
end

# Outside temperature is infact more pleasant than inside.
# Time to open the damn windows!
Delivery::Scheduler.new(inside_temp, outside_temp).schedule
