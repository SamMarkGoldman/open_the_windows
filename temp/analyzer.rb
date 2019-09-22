module Temp
  class Analyzer


    @@target_temp = Config::Temp::TARGET
    @@min_temp = @@target_temp - (Config::Temp::RANGE / 2)
    @@max_temp = @@target_temp + (Config::Temp::RANGE / 2)

    def self.within_pleasant_range?(temp)
      temp > @@min_temp && temp < @@max_temp
    end

    def self.outside_more_pleasant?(inside_temp, outside_temp)
      (@@target_temp - outside_temp).abs < (@@target_temp - inside_temp).abs
    end

    def self.future_prediction(minutes)
      storage = Temp::Storage.new
      storage.load_current_file
      data = storage.recent_data(minutes)

      data.first[:outside] + (data.first[:outside] - data.last[:outside])

    end
  end
end