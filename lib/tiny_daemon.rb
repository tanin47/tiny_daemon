require 'tiny_daemon/version'
require 'tiny_daemon/process_file'

class TinyDaemon
  attr_accessor :app_name, :pid_dir, :log_dir

  START_TIMEOUT = 5
  STOP_TIMEOUT = 30

  def initialize(app_name, pid_dir, log_dir)
    @app_name = app_name
    @pid_dir = pid_dir
    @log_dir = log_dir
  end

  def exit(&block)
    @exit_block = block
  end

  def process
    @process ||= ProcessFile.new(self.app_name, self.pid_dir)
  end

  def start(&block)
    raise "#{self.process.pid_file_path} already exists. The process might already run. Remove it manually if it doesn't." if self.process.get
    
    Process.fork do
      Process.daemon(true, true)

      self.process.store(Process.pid)
      reset_umask
      set_process_name
      redirect_io

      if @exit_block
        trap("TERM") { exit_on_double_signals } # If `kill <pid>` is called, it will be trapped here
      end

      at_exit { clean_process_file }
      block.call
    end

    wait_until_start
    self.process.get
  end

  def stop(timeout_secs = STOP_TIMEOUT)
    pid = self.process.get

    if pid
      begin
        Process.kill('TERM', pid)
      rescue => e
      end

      wait_until_exit(pid, timeout_secs)
    end
  end

  private 
  def wait_until_start
    start_time = Time.now.to_i
    while self.process.get.nil?
      sleep(0.1)

      if (Time.now.to_i - start_time) > START_TIMEOUT
        raise "Waiting too long (for #{START_TIMEOUT} seconds) to start. There might be an exception. Please check the log"
      end
    end
  end

  def wait_until_exit(pid, timeout_secs)
    start_time = Time.now.to_i
    while true
      begin
        Process.kill(0, pid)
      rescue Errno::ESRCH
        break # the process doesn't exist anymore
      rescue ::Exception # for example on EPERM (process exists but does not belong to us)
      end

      sleep(0.1)

      if (Time.now.to_i - start_time) > timeout_secs
        raise "Waiting too long (for #{timeout_secs} seconds) to exit."
      end
    end
  end

  def reset_umask
    File.umask(0000) # We don't want to inherit umask from the parent process
  end

  def set_process_name
    $0 = self.app_name # In `ps aux`, it will show this name
  end

  def log_file
    File.join(self.log_dir, "#{self.app_name}.log")
  end

  def redirect_io
    FileUtils.mkdir_p File.dirname(self.log_dir), :mode => 0755
    FileUtils.touch log_file
    File.chmod(0644, log_file)
    $stdout.reopen(log_file, 'a')
    $stderr.reopen($stdout)
    $stdout.sync = true
  end

  def exit_on_double_signals
    @kill_count ||= 0

    if @kill_count == 0
      @kill_count += 1
      @exit_block.call
    else
      clean_process_file
      puts "TERM is signaled twice. Therefore, we kill the process #{Process.pid} immediately."
      Kernel.exit(0)
    end
  end

  def clean_process_file
    self.process.clean
  end
end