$:.push('lib')

require 'tiny_daemon'

is_running = true

daemon = TinyDaemon.new("tiny_daemon_example", "tmp", "tmp")
daemon.stop
daemon.exit do
  is_running = false
  puts "Being killed gracefully "
end
pid = daemon.start do
  while is_running
    puts Time.now.to_i.to_s
    sleep(1)
  end

  puts "Exit gracefully"
end

puts "It is running in the process #{pid}"