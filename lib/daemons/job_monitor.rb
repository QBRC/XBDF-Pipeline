#!/usr/bin/env ruby

# ./lib/daemons/job_monitor_ctl [start|stop|restart]
# ./lib/daemons/job_monitor_ctl restart


def qstatus job_id = ""
  output = %x[/opt/torque/bin/qstat #{job_id}].split("\n")
  
  # if the job is gone, assume it finished correctly
  return 'C' if output.empty?
  
  output = output[2..-1]
  output.map!{|line|
    line =~ /([^ ]*) *([^ ]*) *([^ ]*) *([^ ]*) *([^ ]*) *([^ ]*) */
    {:job_id => $1, :name => $2, :user => $3, :time => $4, :status => $5, :queue => $6}
    $5
  }
  
  output.size == 1 ? output.first : output
end

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

puts "loading Rails application..."
puts File.dirname(__FILE__) + "/../../config/application"
require File.dirname(__FILE__) + "/../../config/application"

puts "loading envioronment..."
Rails.application.require_environment!

puts "daemon started"

$running = true
Signal.trap("TERM") do 
  $running = false
end

def torque_script(run)
  script=<<-END
#!/bin/bash
#PBS -q pipeline
#PBS -l nodes=1:ppn=4
#PBS -d #{run.path}

export PATH=$PATH:#{run.command.path_directory}
export PLUGIN_DIRECTORY=#{run.command.plugin_directory}

export PL_BOWTIE_DIR=/home/pipeline/plugins/bowtie/

#{run.command_string}
  END
end

def puts str
  Rails.logger.info "job_monitor.rb: #{str}"
end

class String
  def h1
    puts self.center(20, '=')
  end
end

while($running) do
  Rails.logger.auto_flushing = true
  puts "looping"
  
  # submit runs ready to run
  Run.ready_to_run.each{|run|
  # Run.all.each{|run|
    puts "ready to run##{run.id}"
    
    script = torque_script(run)
    script_path = run.path.join("_torque_script.sh")
    unless File.exists?(File.dirname(script_path))
      puts "Error: job folder for run##{run.id} has been deleted."
      next
    end
    File.open(script_path, 'w'){|f| f.write script}
    
    # "Command".h1
    puts command = "/opt/torque/bin/qsub -e #{run.path} #{script_path}"
    
    # "Torque Output".h1
    torque_job_id = %x[#{command}]
    run.torque_job_id = torque_job_id
    
    # "QSTAT".h1
    # output = qstatus(torque_job_id)
    
    run.torque_status = qstatus(run.torque_job_id)
    run.save
  }
  
  Run.to_delete.each do |run|
    puts "stopping run##{run.id}"
    %x[/opt/torque/bin/qdel #{run.torque_job_id}]
    run.torque_status = nil
    run.started_at = nil
    run.ended_at = nil
    run.save
  end
  
  # update the status of each running Run
  Run.running.each do |run|
  # run = Run.first; while true
    
    puts "updating run##{run.id}"
    
    # update the status of each run
    torque_status = qstatus(run.torque_job_id)
    run.torque_status = torque_status
    
    puts "run##{run.id}.status: #{torque_status}"
    
    run.started_at = Time.now if run.started_at.nil? && run.torque_status == 'R'
    run.ended_at = Time.now if torque_status == 'C'
    
    run.save
  end
  
  # $running = false
  time_to_sleep = 5
  puts "sleeping #{time_to_sleep} seconds"
  sleep time_to_sleep
end