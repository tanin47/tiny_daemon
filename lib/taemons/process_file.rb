class Taemons
  class ProcessFile < Struct.new(:app_name, :pid_dir)
    def pid_file_path
      File.join(self.pid_dir, "#{self.app_name}.pid")
    end

    def store(pid)
      raise "#{pid_file_path} already exists. The process might already run. Remove it manually if it doesn't." if File.exists?(pid_file_path)

      FileUtils.mkdir_p(self.pid_dir)
      File.open(pid_file_path, 'w') do |f| 
        f.write("#{pid}")
      end
    end

    def get
      pid = if File.exists?(pid_file_path)
        IO.read(pid_file_path).strip.to_i
      else
        0
      end

      pid == 0 ? nil : pid
    end

    def clean
      FileUtils.rm(pid_file_path) if File.exists?(pid_file_path)
    end
  end
end