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


Run an example
--------------

1. Install all dependencies: `bundle install`
2. Run the example: `bundle exec ruby tests/example.rb`


Daemonize a Rake task
----------------------

It can be used with a Rake task and, ultimately, use with Capistrano comfortably:

```ruby
namespace :daemon do
  task :start => :environment do
    is_running = true

    d = TinyDaemon.new("some_task", "tmp/pids", "log")
    d.stop
    d.exit { is_running = false }
    d.start do
      while is_running
        puts "Test"
        sleep(0.1)
      end
    end
  end

  task :stop => :environment do
    TinyDaemon.new("some_task", "tmp/pids", "log").stop
  end
end
```


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


License
-------------
Do What The Fuck You Want To Public License (http://sam.zoy.org/wtfpl/)

"You just DO WHAT THE FUCK YOU WANT TO."

