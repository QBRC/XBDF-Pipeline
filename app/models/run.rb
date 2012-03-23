class Run < ActiveRecord::Base
  attr_accessible :command_id, :job_id, :waiting_on_run_id, :torque_job_id, :xml_data, :command_string, :torque_status, :cpu_time, :started_at, :ended_at
  
  include XmlHelper
  
  belongs_to :command
  belongs_to :job

  def after_create
    Dir.mkdir path
  end
  
  def path
    dirname = "#{id}_#{command.alias.gsub(' ','_').underscore}"
    return waiting_on_run.path.join(dirname) if waiting_on_run
    job.path.join(dirname)
  end
  
  def files
    Dir.mkdir path unless Dir.exists? path
    Dir.entries(path).find_all{|filename|
      filename != '.' and filename != '..' and !(filename =~ /^\d*_[^ ]*$/)
    }
  end
  
  def waiting_on_run
    # return nil if [nil, -1].index waiting_on_run_id
    return nil unless waiting_on_run_id
    Run.find(waiting_on_run_id)
  end
  
  def command_id=(id)
    puts "CALLING SPECIAL COMMAND ID"
    self.xml_data = Command.find(id).default_xml_preferences_data
    super(id)
  end
  
  def command=(command)
    command_id = command.id
  end
  
  def xml
    return nil unless xml_data
    @xml ||= Nokogiri::XML xml_data
  end
  
  def status
    case torque_status
    when 'C' then 'completed after having run'
    when 'E' then 'exiting after having run.'
    when 'H' then 'held.'
    when 'Q' then 'queued, eligible to run or routed.'
    when 'R' then 'running.'
    when 'T' then 'being moved to new location.'
    when 'W' then 'waiting for its execution time (-a option) to be reached.'
    when 'S' then '(Unicos only) suspend'
      
    when 'A' then 'waiting to be submitted to Torque' # used internally
    when 'X' then 'waiting to be deleted from Torque' # used internally
    when nil then 'not started'
    end
  end

  def stop
    self.mark_for_deletion = true
    self.torque_status = 'X'
    save
  end
    
  def ready?
    torque_status && torque_status == 'A'
  end

  def reset
    self.update_attributes(:torque_status => nil, :torque_job_id => nil, :started_at => nil, :ended_at => nil, :mark_for_deletion => nil)
  end
  
  def start
    # self.update_attributes(:torque_status => 'A', :torque_job_id => nil, :started_at => nil, :ended_at => nil, :mark_for_deletion => nil)
    self.torque_status = 'A'
    self.torque_job_id = nil
    self.started_at = nil
    self.ended_at = nil
    self.mark_for_deletion = nil
    self.save
  end
  
  def finished?
    finished_successfully?
  end

  def finished_successfully?
    # may need to update this if torque/daemon don't work this way
    (ended_at && ended_at < Time.now && torque_status && %w(C X).index(torque_status))
  end
  
  def stdout
    @stdout ||= file_content path.join("stdout.log")
  end
  
  def stderr
    @stderr ||= file_content path.join("stderr.log")
  end
  
  def update_xml_attributes(form_data)
    builder = Nokogiri::XML::Builder.new do |doc|
      doc.send(self.command.alias){
        form_data.each{|name, value|
          doc.send(name, value)
        } if form_data # form might be empty for simple commands
      }
    end
    
    errors = xml_errors(builder.to_xml, self.command.xsd_data)
    errors.each{|error|
      self.errors.add(error[0], error[1])
    }
    
    return false unless errors.empty?
    
    self.xml_data = builder.to_xml
    self.save
    
    return false unless self.command_string = build_command
    self.save
  end
  
  def self.ready_to_run
    Run.find_all_by_torque_job_id(nil).find_all{|run|
      if run.waiting_on_run_id == nil
        run.ready?
      else
        run.waiting_on_run.finished_successfully?
      end
    }
  end
  
  def self.to_delete
    Run.find_all_by_mark_for_deletion(true)
  end
  
  def self.running
    Run.where('ended_at is NULL AND torque_job_id is NOT NULL')
  end
  
  def running?
    ended_at == nil and started_at and started_at <= Time.now
  end
  
  def expected_files
    args = self.command.expected_file_args
    args.map{|a| a[:default]}
  end
  
  def roles
    @roles = {}
    command.xml.search("arg").each{|a|
      if a[:type] == "filepath" and a[:role]
        @roles[a[:role]] = path.join(self.xml.at(a[:name]) || a[:default])
      end
    }
    @roles
  end  
  
  private 
    
  def file_content filepath    
    return nil unless File.exists? filepath
    
    max_size = 3000
    content = if (size = File.size(filepath)) > max_size
      content = IO.readlines(filepath).join
      size = File.size filepath
      temp = content[0..(max_size/3)]
      temp << "\n\n" + '.'*20 + "#{nice_bytes size} OMITTED" + '.'*20 + "\n\n"
      temp << content[[-(max_size/3), -content.size].max..-1]
      temp
    else
      File.read(filepath)
    end
    
    CGI::escapeHTML(content).gsub("\n", '<br />').gsub("\t", "&nbsp;"*4).html_safe
  end

  def build_command
    program_name = command.alias
    program_xml = command.xml
    
    command_string = command.path
    
    # xml should already be valid, so don't waste time checking
    
    right_positional_args = []
    left_positional_args = []
    args = []
    stdout = path + "stdout.log"
    stderr = path + "stderr.log"

    program_xml.search("arg").each{|argument|      
      flag = argument[:flag]
      value = argument[:default]
      
      next unless flag
      
      # user specified arguments have prescidence over default arguments
      if user_argument = xml.at(argument[:name])
        value = user_argument.inner_text
      end

      # arguments specified via params {} have prescidence over user specified arguments
      # if params[argument[:name].to_sym]
      #   value = params[argument[:name].to_sym]
      # end

      # if there is no value 
      if !value or value == "" or value.downcase == "false"
        # throw error if it's required
        if argument[:required]
          self.errors.add argument[:name], "required"
          return false
        end
        # else
        next
      end

      if flag =~ /^\$(\-)?(\d*)$/
        position = $2.to_i
        
        # if it has a minus sign in front of the number, add it as a left-side argument
        p $1
        if $1 == '-'
          left_positional_args[position] = value
        else
          right_positional_args[position] = value
        end
      # elsif flag.downcase == "$stdout"
      #   stdout = value
      # elsif flag.downcase == "$stdout"
      #   stderr = value
      elsif value.downcase == 'true'
        args << "#{flag}"
      else
        args << "#{flag} #{value}"
      end
    }

    command_string << left_positional_args.join(" ")
    command_string << " "
    command_string << args.join(" ")
    command_string << " "
    command_string << right_positional_args.join(" ")
    
    command_string << " >#{stdout}"
    command_string << " 2>#{stderr}"

    command_string
  end

  # in leu of having access to number_to_human_size
  K = 2.0**10
  M = 2.0**20
  G = 2.0**30
  T = 2.0**40
  def nice_bytes( bytes, max_digits=3 )
    value, suffix, precision = case bytes
      when 0...K
        [ bytes, 'b', 0 ]
      else
        value, suffix = case bytes
          when K...M then [ bytes / K, 'kB' ]
          when M...G then [ bytes / M, 'MB' ]
          when G...T then [ bytes / G, 'GB' ]
          else            [ bytes / T, 'TB' ]
        end
        used_digits = case value
          when   0...10   then 1
          when  10...100  then 2
          when 100...1000 then 3
        end
        leftover_digits = max_digits - used_digits
        [ value, suffix, leftover_digits > 0 ? leftover_digits : 0 ]
    end
    "%.#{precision}f#{suffix}" % value
  end
end
