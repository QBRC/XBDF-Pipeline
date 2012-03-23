class Organization < ActiveRecord::Base
  attr_accessible :name, :description, :url, :alias
  has_and_belongs_to_many :students
  has_and_belongs_to_many :users
  
  # accepts_nested_attributes_for :students, :allow_destroy => true
  validates_presence_of :name
  validates_presence_of :alias
  validates_uniqueness_of :alias
  validates_format_of :alias, :with => /^[^\s]*$/i, :message => "can't have any spaces"
  validates_format_of :url, :with => URI::regexp(%w(http https)), :allow_nil => true, :message => "isn't a website"
  
  def url=(u)
    super(nil) if u.empty?
    u.gsub!(/\s/,'')
    u = "http://" + u unless u.index('http://')
    super(u)
  end
  
  def email_list
    students.map{|user| "#{user.name} <#{user.email}>"}.join("; ")
  end
  
  def create_google_group_url
    "https://groups.google.com/groups/create?hl=en&noredirect=true&name=#{CGI.escape 'SMU ' + name}&addr=#{CGI.escape 'smu_' + self.alias}&desc=#{CGI.escape description}&members_new=#{CGI.escape email_list}"
  end
end