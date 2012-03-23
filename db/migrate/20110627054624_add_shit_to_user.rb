class AddShitToUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :username
    
    create_table :organizations_users, :id => false do |t|
      t.integer :organization_id
      t.integer :user_id
    end
  end

  def self.down
      add_column :users, :username, :string
      drop_table :organizations_users
  end
end
