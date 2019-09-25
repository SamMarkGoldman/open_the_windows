#!/usr/bin/env ruby
require_relative 'config'
require_relative 'temp'

require "webrick"

=begin
    Example usage: 
        http://localhost:1234/ shows current temp readings
        http://localhost:1234/history?count=10 fetches the last [count] readings from the history file
=end


class TemperatureServlet < WEBrick::HTTPServlet::AbstractServlet
    def do_GET (request, response)
        response.status = 200
        response.content_type = "text/plain"
        result = nil
        
        case request.path
            when "/history"
                count = request.query["count"]
                result = "not yet implemented"
            else
                inside_thermometer = Temp::Reader.new(Config::Temp::Devices::INSIDE)
                outside_thermometer = Temp::Reader.new(Config::Temp::Devices::OUTSIDE)
                outside_temp = outside_thermometer.read
                inside_temp = inside_thermometer.read

                result = "inside: #{inside_temp}\noutside: #{outside_temp}"
        end
        
        response.body = result.to_s + "\n"
    end
end

server = WEBrick::HTTPServer.new(:Port => 1234)

server.mount "/", TemperatureServlet

trap("INT") {
    server.shutdown
}

server.start