require './tests/test_helper'
require 'tiny_daemon'

def test_daemon(use_signal) 
  is_running = true
  exit_invoked = false
  exit_gracefully = false

  File.delete('tmp/test_tiny_daemon.log')

  daemon = TinyDaemon.new("test_tiny_daemon", "tmp", "tmp")
  daemon.stop
  daemon.exit do
    is_running = false
    exit_invoked = true
  end
  pid = daemon.start do
    while is_running
      puts Time.now.to_i.to_s
      sleep(0.1)
    end

    exit_gracefully = true
  end

  assert(true, File.exists?('tmp/test_tiny_daemon.log'))
  assert(true, File.exists?('tmp/test_tiny_daemon.pid'))

  sleep(3)

  if use_signal
    Process.kill("TERM", pid)
  else
    daemon.stop
  end

  assert(true, exit_invoked)
  assert(true, exit_gracefully)
end

describe TinyDaemon do
  it "fork a new process and signals TERM" do
    test_daemon(true)
  end

  it "can stop programmatically" do
    test_daemon(false)
  end

  it "starts twice with no problem" do
    is_running = true

    daemon = TinyDaemon.new("test_tiny_daemon", "tmp", "tmp")
    daemon.stop
    daemon.exit do
      is_running = false
    end
    pid1 = daemon.start do
      while is_running
        puts Time.now.to_i.to_s
        sleep(0.1)
      end
    end

    daemon.stop
    pid2 = daemon.start do
      while is_running
        puts Time.now.to_i.to_s
        sleep(0.1)
      end
    end

    assert_equal(false, pid1 == pid2)
    assert_raises(Errno::ESRCH) { 
      Process.kill(0, pid1)
    }
    assert_equal(1, Process.kill(0, pid2))

    daemon.stop
  end

  it "should timeout on start" do
    daemon = TinyDaemon.new("test_tiny_daemon", "tmp", "tmp")
    daemon.stop

    assert_raises(RuntimeError) {
      daemon.start do
        raise 'exception'
      end
    }
  end

  it "should timeout on stop" do
    is_running = true

    daemon = TinyDaemon.new("test_tiny_daemon", "tmp", "tmp")
    daemon.stop
    daemon.exit do
      puts "exit invoked"
    end
    daemon.start do
      while is_running
        puts Time.now.to_i.to_s
        sleep(0.1)
      end
    end

    assert_raises(RuntimeError) { daemon.stop(1) }

    is_running = false
  end
end