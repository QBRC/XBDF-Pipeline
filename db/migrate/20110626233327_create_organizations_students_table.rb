class CreateOrganizationsStudentsTable < ActiveRecord::Migration
  def self.up
    create_table :organizations_students, :id => false do |t|
      t.integer :organization_id
      t.integer :student_id
    end 
  end

  def self.down
    drop_table :organizations_students 
  end
end
