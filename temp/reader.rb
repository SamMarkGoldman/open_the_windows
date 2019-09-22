module Temp
  class Reader
    def initialize(address)
      @address = address
    end

    def read
      `python #{Config::ROOT_DIR}/read_raw_temp.py #{@address}`.to_f.round(Config::Temp::MEASUREMENT_PRECISION)
    end

    private

    def mock_read
      if (@address === Config::Temp::Devices::INSIDE)
        return 75
      end
      if (@address === Config::Temp::Devices::OUTSIDE)
        return 70
      end
    end
  end
end