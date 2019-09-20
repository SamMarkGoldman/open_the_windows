class TempReader
  def initialize(address)
    @address = address
  end

  def read
    `python #{File.expand_path(File.dirname(__FILE__))}/read_raw_temp.py #{@address}`.to_f
  end

  private

  def mock_read
    if (@address === Config::Temp::Devices::INSIDE)
      return 65
    end
    if (@address === Config::Temp::Devices::OUTSIDE)
      return 72
    end
  end
end