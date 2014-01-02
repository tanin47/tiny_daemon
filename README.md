tiny_daemon
================

* It daemonizes a Ruby block and supports graceful exiting.
* It only supports and guarantee running only one process at any moment


How to use
--------------

Please include this into your Gemfile:

```
gem 'tiny_daemon'
```

```ruby
p = TinyDaemon.new("test_process", "pids", "log")

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

There will be a pid file at pids/test_process.pid. The log file will be at log/test_process.log.

We can issue `kill [pid]` in order to exit the process gracefully. Please note that using `kill -9 [pid]` will terminate the process immediately.


Run example
--------------

1. Install all dependencies: `bundle install`
2. Run the example: `bundle exec ruby tests/example.rb`


Requirement
--------------

* >= Ruby 2.0
* *nix platform


How to develop
--------------

1. Install all dependencies: `bundle install`
2. Run all tests: `bundle exec rake test`
3. Start developing


Author
--------------

Tanin Na Nakorn

