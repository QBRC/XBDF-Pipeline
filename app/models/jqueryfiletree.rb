class Jqueryfiletree
  
  def initialize(root)
    @root = root
  end

  def get_dirs(path=".")
    path = "" if path.nil?
    @path = File.join(File.expand_path(@root), path)
    @dirs = []
    if File.exists?(@path)
      Dir.entries(@path).each do |dir|
        if File.directory?(File.join(@path, dir)) && dir[0,1]!="."
          @dirs << dir
        end
      end
    end
    @dirs
  end

  def get_files(path=".")
    path = "" if path.nil?
    @path = File.join(File.expand_path(@root), path)
    @files = []
    if File.exists?(@path)
      Dir.entries(@path).each do |file|
        if File.file?(File.join(@path, file))
          @files << file
        end
      end
    end
    @files
  end
  
  def get_expected_files(path=".")
    @path = File.join(File.expand_path(@root), path)
    if File.basename(File.dirname(@path)) =~ /(\d*)_/
      runs = Run.find_all_by_id($1)
      return [] if runs.empty?
      @run = runs.first
      @run.expected_files
      return @run.expected_files
    end
    []
  end

  def get_content(path=".")
      [get_dirs(path), get_files(path), get_expected_files(path)]
  end
end
