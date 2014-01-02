require 'fileutils'
require './tests/test_helper'
require 'tiny_daemon/process_file'

describe TinyDaemon::ProcessFile do
  before(:each) do
    File.delete("tmp/test_app.pid") if File.exists?("tmp/test_app.pid")
    assert_equal(false, File.exists?("tmp/test_app.pid"))
  end

  it "uses correct file path" do
    assert_equal("tmp/test_app.pid", TinyDaemon::ProcessFile.new("test_app", "tmp").pid_file_path)
  end

  it "deletes pid file" do
    FileUtils.touch("tmp/test_app.pid")
    assert_equal(true, File.exists?("tmp/test_app.pid"))

    TinyDaemon::ProcessFile.new("test_app", "tmp").clean
    assert_equal(false, File.exists?("tmp/test_app.pid"))
  end

  it "stores and gets" do
    pf = TinyDaemon::ProcessFile.new("test_app", "tmp")
    pf.store(1111)

    assert_equal(1111, pf.get)
  end

  it "doesn't store" do
    pf = TinyDaemon::ProcessFile.new("test_app", "tmp")
    pf.store(1111)

    assert_raises(RuntimeError) { 
      pf.store(1112)
    }

    assert_equal(1111, pf.get)
  end
end