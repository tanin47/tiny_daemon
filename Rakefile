require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs = FileList['lib/**/*.rb']
  t.test_files = FileList['tests/**/*_test.rb']
  t.verbose = true
end