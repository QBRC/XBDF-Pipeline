module XmlHelper
  def validate_xml(xml, xsd)
    # can be either xml string or filepath to the xml
    xml = File.read(xml) unless xml.index("<?xml")
    xsd = File.read(xsd) unless xsd.index("<?xml")
    
    xsd = Nokogiri::XML::Schema(xsd)
    doc = Nokogiri::XML(xml)
    # 
    # xsd.validate(doc).each do |error|
    #   puts error.message
    #   p error
    # end
    xsd.validate(doc).map{|error|
      "line #{error.line}: #{error.message}"
    }
  end
  
  def xml_errors(xml, xsd)
    errors = validate_xml(xml, xsd)
    # errors = ["line 8: Element 'min-anchor-length': [facet 'minInclusive'] The value '1' is less than the minimum value allowed ('3').", "line 8: Element 'min-anchor-length': '1' is not a valid value of the local atomic type."]
    
    errors.map{|error|
      error =~ /Element \'([^\']*)\': (.*)/
      [$1, $2]
    }
  end
end
# 
# include XmlHelper
# xml_errors