class AddMarkForDeletionToRuns < ActiveRecord::Migration
  def self.up
    add_column :runs, :mark_for_deletion, :boolean
  end

  def self.down
    remove_column :runs, :mark_for_deletion
  end
end
