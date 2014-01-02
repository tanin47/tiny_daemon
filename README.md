Taemons
================

It daemonizes a Ruby block and supports graceful exiting.

It also maintains a pid file, so that it doesn't run more than 1 process at any moment.


Requirement
--------------

* >= Ruby 2.0
* *nix platform


How to
--------------


```ruby
p = Taemons.new("test_process", "pids", File.join(Dir.pwd, 'log'))

p.stop # Allow only one instance to run at any moment

p.exit do
  is_running = false
  puts "The process #{Process.pid} is being killed gracefully "
end

p.start do
  while is_running
    puts "Test"
    sleep(1)
  end

  puts "The process #{Process.pid} exited gracefully"
end
```

There will be a pid file at pids/test_process.pid.

We can issue `kill [pid]` in order to exit the process gracefully. Please note that using `kill -9 [pid]` will terminate the process immediately.

Author
--------------

Tanin Na Nakorn

