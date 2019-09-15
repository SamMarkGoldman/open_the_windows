require 'pry'
require 'date'
require_relative 'temp_reader'
require_relative 'config'

target_temp = Config::TARGET_TEMP
min_temp = target_temp - (Config::TEMP_RANGE / 2)
max_temp = target_temp + (Config::TEMP_RANGE / 2)

inside_thermometer = TempReader.new(0)
outside_thermometer = TempReader.new(1)
outside_temp = outside_thermometer.read

if outside_temp < min_temp || outside_temp > max_temp
  puts 'Outside temperature is not within pleasant range.'
  exit 0
end

inside_temp = inside_thermometer.read
if (target_temp - outside_temp).abs > (target_temp - inside_temp).abs
  puts 'Outside temperature is less pleasant than inside.'
end

# now we dance