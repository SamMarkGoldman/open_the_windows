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
        response.content_type = "text/html"
        result = nil
        
        case request.path
            when "/history"
                count = request.query["count"]
                result = "not yet implemented"
            else
                last_reading = Temp::Storage.new.last_reading
                inside_temp = last_reading[1]
                outside_temp = last_reading[2]

                result = %{
                    <html>
                        <div style="text-align: center; font-size: 700%; position: relative; top: 50%; transform: translateY(-50%);">
                            <div>
                                inside: #{inside_temp}&deg;
                            </div>
                            <div>
                                outside: #{outside_temp}&deg;
                            </div>
                        </div>
                    </html>
                }
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