class CreateRuns < ActiveRecord::Migration
  def self.up
    create_table :runs do |t|
      t.integer :command_id
      t.integer :job_id
      t.integer :waiting_on_run_id
      t.integer :torque_job_id
      t.text :xml_data
      t.string :command_string
      t.string :torque_status, :limit => 1
      t.integer :cpu_time
      t.datetime :started_at
      t.datetime :ended_at
      t.timestamps
    end
  end

  def self.down
    drop_table :runs
  end
end
