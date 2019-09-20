class TempReader
  def initialize(address)
    @address = address
  end

  def read
    # needs real impl
    # return 70

    if (@address === Config::Temp::Devices::INSIDE)
      return 65
    end
    if (@address === Config::Temp::Devices::OUTSIDE)
      return 72
    end
  end
end