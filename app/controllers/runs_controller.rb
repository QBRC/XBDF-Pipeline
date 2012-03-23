class RunsController < ApplicationController
  before_filter :find_job
  before_filter :daemon_running?
  
  def index
    @runs = Run.all
  end

  def show
    @run = Run.find(params[:id])
    @command = @run.command
    
    respond_to do |format|
      format.html
      format.xml{ render :xml => @run.xml}
    end
  end

  def new
    @run = Run.new
    @run.job_id = Job.find(params[:job_id]).id
    @run.command_id = Command.find(params[:command_id]).id
    if params[:waiting_on_run_id]
      @run.waiting_on_run_id = Run.find(params[:waiting_on_run_id]).id
      @roles = Run.find(@run.waiting_on_run_id).roles
    end
    @command = @run.command
  end

  def create
    @run = Run.new(params[:run])
    @run.job_id = Job.find(params[:job_id]).id
    @command = @run.command
    if @run.save && @run.update_xml_attributes(params[:xml])
      redirect_to job_path(@job), :notice  => "Successfully updated run."
    else
      render :action => 'new'
    end
  end

  def edit
    @run = Run.find(params[:id])
    @command = @run.command
  end

  def update
    @run = Run.find(params[:id])
    @command = @run.command
    if @run.update_xml_attributes(params[:xml])
      redirect_to job_path(@job), :notice  => "Successfully updated run."
    else
      render :action => 'edit'
    end
  end
  
  def stop
    @run = Run.find(params[:id])
    @run.stop
    
    redirect_to job_url(@job), :notice => "Stopping run."
  end

  def restart
    @run = Run.find(params[:id])
    @run.reset
    redirect_to job_url(@job), :notice => "Run restarted."
  end

  def destroy
    @run = Run.find(params[:id])
    @run.destroy
    redirect_to job_url(@job), :notice => "Successfully destroyed run."
  end
  
  # finished_successfully?()

  # load_xml(xml)
  
  private
  
  def find_job
    @job ||= Job.find(params[:job_id])
  end
end
