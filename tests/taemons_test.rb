require './tests/test_helper'
require './lib/taemons'

describe Taemons do
  it "does something" do
    is_running = true

    taemon = Taemons.new("test", "tmp", "tmp")
    taemon.exit do
      is_running = false
      puts "Being killed gracefully "
    end
    pid = taemon.start do
      while is_running
        puts Time.now.to_i.to_s
        sleep(1)
      end

      puts "Exit gracefully"
    end

    # Why does this run on another thread?
    puts "HELLO"

    sleep(5)
    puts "YEAH"
    Process.kill("TERM", pid)
  end
end