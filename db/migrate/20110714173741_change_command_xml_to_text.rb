class ChangeCommandXmlToText < ActiveRecord::Migration
  def self.up
    remove_column :commands, :xml_binary
    remove_column :commands, :xsd_binary
    remove_column :commands, :default_xml_preferences_binary
    
    add_column :commands, :xml_data, :text
    add_column :commands, :xsd_data, :text
    add_column :commands, :default_xml_preferences_data, :text
  end

  def self.down
  end
end
