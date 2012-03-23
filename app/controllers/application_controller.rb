class ApplicationController < ActionController::Base
  include ControllerAuthentication
  protect_from_forgery
  
  def daemon_running?
    @daemon_pid_path ||= Rails.root.join("log/job_monitor.rb.pid")
    @daemon_pid ||= File.exists?(@daemon_pid_path) ? File.open(@daemon_pid_path).read.strip : nil
  end
end
