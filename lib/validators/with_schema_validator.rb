class WithSchemaValidator < ActiveModel::EachValidator
  require "#{Rails.root}/app/helpers/xml_helper.rb"
  include XmlHelper

  
  def validate_each(object, attribute, value)
    puts "VALIDATE_EACH BEING CALLED HERE: #{attribute}"
    puts "#{value}"
    
    if attribute.to_s == "xml_data"
      schema = Rails.public_path + "/command.xsd"
    elsif attribute.to_s == "xsd_data"
      return
    else
      schema = object.xsd_data if attribute.to_s == "default_xml_preferences_data"
    end
    
    unless (errors = validate_xml(value, schema)).empty?
      object.errors[attribute] << errors
    end
  end
end