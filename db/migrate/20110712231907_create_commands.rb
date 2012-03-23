class CreateCommands < ActiveRecord::Migration
  def self.up
    create_table :commands do |t|
      t.string :alias
      t.string :path
      t.text :description
      t.string :module
      t.string :name
      t.string :version
      t.binary :xml_binary
      t.binary :xsd_binary
      t.binary :default_xml_preferences_binary
      t.timestamps
    end
  end

  def self.down
    drop_table :commands
  end
end
