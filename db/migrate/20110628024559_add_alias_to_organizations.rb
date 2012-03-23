class AddAliasToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :alias, :string
  end

  def self.down
    remove_column :organizations, :alias
  end
end
