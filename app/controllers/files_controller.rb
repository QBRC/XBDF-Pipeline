class FilesController < ApplicationController
  protect_from_forgery :only => []
  def index
    puts "START FILESCONTROLLER"
    p params
    @run = Run.find(params[:run_id]) if params[:run_id]
    @job = Job.find(params[:job_id])
    
    puts "params[:dir]=#{params[:dir]}"
    @parent = params[:dir]
    if @parent.nil? || @parent == "" || @parent == "/"
      @parent = JOB_FILES_PATH.join @job.path
    end
    
    p @parent
    @dir = Jqueryfiletree.new(@parent).get_content
    
    p @dir
    puts "END FILESCONTROLLER"
    render :layout => false
  end
  
  def show
    render :text => "lol" 
  end
end