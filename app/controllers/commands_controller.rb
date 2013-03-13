class CommandsController < ApplicationController
  before_filter :daemon_running?
  
  def index
    @commands = Command.all
  end

  def show
    @command = Command.find(params[:id])
  end
  
  def download
    @command = Command.find(params[:id])
    file = params[:filename]
    file_name = @command.alias
    t = Tempfile.new("my-temp-filename-#{Time.now}")
    Zip::ZipOutputStream.open(t.path) do |z|
      Dir[Rails.root.join("doc/#{@command.id}_*")].each{|filename|
        title = File.basename(filename).sub("#{@command.id}_", '')
        z.put_next_entry(title)
        z.puts File.open(filename).read.gsub('\n', "\n")
      }
      
      z.put_next_entry(@command.alias + ".xml")
      z.puts @command.xml_data
      z.put_next_entry(@command.alias + ".xsd")
      z.puts @command.xsd_data
      z.put_next_entry(@command.alias + "_defaults.xml")
      z.puts @command.default_xml_preferences_data
    end
    send_data data, :type => 'application/zip', :disposition => 'attachment', :filename => file_name
    t.close
  end

  def new
    @command = Command.new
  end

  def create
    @command = Command.new(params[:command])
    if @command.save
      redirect_to @command, :notice => "Successfully created command."
    else
      render :action => 'new'
    end
  end

  def edit
    @command = Command.find(params[:id])
  end

  def update
    @command = Command.find(params[:id])
    if @command.update_attributes(params[:command])
      redirect_to @command, :notice  => "Successfully updated command."
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @command = Command.find(params[:id])
    @command.destroy
    redirect_to commands_url, :notice => "Successfully destroyed command."
  end
end
