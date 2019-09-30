#!/usr/bin/env ruby
require_relative 'config'
require_relative 'temp'

require "webrick"


=begin
    Example usage: 
        http://localhost:1234/ shows current temp readings
        http://localhost:1234/history?days=5 fetches the last [days] readings from the history file
=end


class TemperatureServlet < WEBrick::HTTPServlet::AbstractServlet
    def chart_data(days)
        storage = Temp::Storage.new
        storage.load_current_file
        storage.recent_data(days * 1440)
    end

    def prepare_time_labels(data)
        data.map { |d| d[:time].strftime("%m/%-d %H:%M") }
    end

    def do_GET (request, response)
        response.status = 200
        result = nil
        
        case request.path
            when "/js/chart_utils.js"
                response.content_type = "application/javascript"
                result = File.read("js/chart_utils.js")
            when "/history"
                response.content_type = "text/html"
                days = request.query["days"].to_i
                data = chart_data(days).reverse

                times = prepare_time_labels(data)
                inside_temps = data.map { |d| d[:inside] }
                outside_temps = data.map { |d| d[:outside] }

                result = %{
                    <html>
                        <script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>
                        <script src="js/chart_utils.js"></script>
                        <body>
                            <div style="width:100%;"><div class="chartjs-size-monitor"><div class="chartjs-size-monitor-expand"><div class=""></div></div><div class="chartjs-size-monitor-shrink"><div class=""></div></div></div>
                                <canvas id="canvas" style="display: block;" width="100" height="40" class="chartjs-render-monitor"></canvas>
                            </div>
                            
                            <script>
                                var config = {
                                    type: 'line',
                                    data: {
                                        labels: #{times},
                                        datasets: [{
                                            label: 'Inside',
                                            backgroundColor: window.chartColors.green,
                                            borderColor: window.chartColors.green,
                                            data: #{inside_temps},
                                            fill: false,
                                        }, {
                                            label: 'Outside',
                                            fill: false,
                                            backgroundColor: window.chartColors.blue,
                                            borderColor: window.chartColors.blue,
                                            data: #{outside_temps},
                                        }]
                                    },
                                    options: Config,
                                };

                                window.onload = function() {
                                    var ctx = document.getElementById('canvas').getContext('2d');
                                    window.myLine = new Chart(ctx, config);
                                };

                                var colorNames = Object.keys(window.chartColors);
                            </script>
                        </body>
                    </html>
                }
            else
                response.content_type = "text/html"
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