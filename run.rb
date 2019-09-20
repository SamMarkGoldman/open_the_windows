require 'pry'
require 'date'
require_relative 'config'
require_relative 'delivery'
require_relative 'temp_reader'


target_temp = Config::Temp::TARGET
min_temp = target_temp - (Config::Temp::RANGE / 2)
max_temp = target_temp + (Config::Temp::RANGE / 2)

inside_thermometer = TempReader.new(Config::Temp::Devices::INSIDE)
outside_thermometer = TempReader.new(Config::Temp::Devices::OUTSIDE)
outside_temp = outside_thermometer.read
inside_temp = inside_thermometer.read

puts "inside: #{inside_temp}\noutside: #{outside_temp}"

if outside_temp < min_temp || outside_temp > max_temp
  puts 'Outside temperature is not within pleasant range.'
  exit 0
end

if (target_temp - outside_temp).abs > (target_temp - inside_temp).abs
  puts 'Outside temperature is less pleasant than inside.'
  exit 0
end

# Outside temperature is infact more pleasant than inside.
# Time to open the damn windows!
Delivery::Scheduler.new(inside_temp, outside_temp).schedule
