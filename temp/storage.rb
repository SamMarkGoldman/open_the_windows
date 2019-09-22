require 'fileutils'

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
      unless File.file?(file_path)
        return []
      end
      File.readlines(file_path)
    end

    private

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
