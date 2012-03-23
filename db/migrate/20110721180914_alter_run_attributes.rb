class AlterRunAttributes < ActiveRecord::Migration
  def self.up
    change_column :runs, :command_string, :text
  end

  def self.down
  end
end

# 1. change order of first argument to -1
# 2. Start job with head -n 1000 on test.fastq
# 3. cufflinks.xml