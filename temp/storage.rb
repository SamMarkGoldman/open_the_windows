require 'fileutils'
require 'time'

module Temp
  class Storage
    PATH = "#{Config::ROOT_DIR}#{Config::Temp::STORAGE_DIR}"

    def append_current_reading(inside, outside)
      unless File.directory?(File.dirname(file_path))
        FileUtils.mkdir_p(dir_name)
      end

      File.open(file_path, 'a+') do |f|
        f.puts "#{Time.now},#{inside},#{outside}"
      end
    end

    def load_current_file
      @readings = File.file?(file_path) ? File.readlines(file_path) : []     
    end

    def recent_data(minutes)
      seconds = minutes * 60
      now = Time.now
      [].tap do |slice|
        @readings.reverse_each do |r|
          reading = decode_reading(r)
          slice << reading
          break if now - reading[:time] > seconds
        end
      end
    end

    def last_reading
      `tail -n 1 #{file_path}`.split(',').map(&:strip)
    end

    private

    def decode_reading(reading)
      split_reading = reading.split(',')
      {
        time: Time.parse(split_reading[0]),
        inside: split_reading[1].to_f,
        outside: split_reading[2].to_f,
      }
    end

    def file_name(date)
      "#{date.year}/#{date.month.to_s.rjust(2, '0')}.data"
    end

    def file_path
      "#{PATH}/#{file_name(Time.now)}"
    end

    def dir_name
      File.dirname(file_path)
    end
  end
end
