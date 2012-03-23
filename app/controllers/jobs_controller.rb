class JobsController < ApplicationController
  before_filter :daemon_running?
  
  def index
    @jobs = Job.all.reverse
  end

  def show
    @job = Job.find(params[:id])
    @runs = @job.runs
    @nested_run_ids = @job.nested_run_ids
    
    respond_to do |format|
       format.html
       format.zip #{render :data => Zippy.new('foo.txt' => 'bar').data}
     end
  end
      
  def download
    file_name = "pictures.zip"
    t = Tempfile.new("my-temp-filename-#{Time.now}")
    Zip::ZipOutputStream.open(t.path) do |z|
      runs.each do |run|
        title = run.command.alias + ".xml"
        z.put_next_entry(title)
        z.print run.xml
      end
    end
    send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => file_name
    t.close
  end
  
  def start_job
    @job = Job.find(params[:id])
    @job.runs.each{|run|
      # don't start a run that's finished; those runs need to be reset first
      if !run.finished? && run.waiting_on_run_id == nil
        run.start
      end
      
      # supports adding a command to a completed run
      if !run.finished? && run.waiting_on_run && run.waiting_on_run.finished?
        run.start
      end
    }
    
    redirect_to @job, :notice => 'Started'
  end

  def new
    @job = Job.new
  end

  def create
    @job = Job.new(params[:job])
    if @job.save
      redirect_to @job, :notice => "Successfully created job."
    else
      render :action => 'new'
    end
  end

  def edit
    @job = Job.find(params[:id])
  end

  def update
    @job = Job.find(params[:id])
    if @job.update_attributes(params[:job])
      redirect_to @job, :notice  => "Successfully updated job."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @job = Job.find(params[:id])
    @job.destroy
    redirect_to jobs_url, :notice => "Successfully destroyed job."
  end
end
