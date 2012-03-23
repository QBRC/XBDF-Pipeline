class Job < ActiveRecord::Base
  attr_accessible :name, :user_id
  
  belongs_to :user
  has_many :runs, :dependent => :destroy
  
  # DEPRECATION WARNING: Base#after_create has been deprecated, please use Base.after_create :method instead. (called from <class:Job> at /Users/cgenco/Dropbox/School_11-12/UTSW/pipeline/app/models/job.rb:7)
  def after_create
    Dir.mkdir path
  end
  
  def status
    
  end
  
  def running?
    self.runs.each{|run| return true if run.running?}
    false
  end
  
  def finished?
    self.runs.inject(true){|tf, run| run.finished? && tf}
  end
  
  def path
    dirname = "#{id}_#{name.gsub(' ','_').underscore}"
    JOB_FILES_PATH.join(dirname)
  end
  
  def nested_run_ids
    flat_runs = self.runs.map{|run| {:id => run.id, :parent_id => run.waiting_on_run_id}}
    tree = make_tree(flat_runs)
  end
  
  private
  
  def make_tree(array, parent_id = nil)
    children = []
    array.each{|e| children << e[:id] if e[:parent_id] == parent_id}
    array.delete_if{|e| e[:parent_id] == parent_id}
    
    children.map{|child| [child, make_tree(array, child)]}
  end
end