class Command < ActiveRecord::Base
  include XmlHelper
  attr_accessible :alias, :path, :description, :module, :name, :version, :xml_data, :xsd_data, :default_xml_preferences_data, :upload
  
  has_many :runs
  
  before_validation :parse_xml_data
  validates :xml_data, :with_schema => true
  validates :xsd_data, :with_schema => true
  validates :default_xml_preferences_data, :with_schema => true
  
  after_create :create_plugin_directory, :create_documentation
  
  def xml_data=(input_data)
    input_data = input_data.read if input_data.respond_to? :read
    super input_data
  end
  
  def xml
    return nil unless xml_data
    @xml ||= Nokogiri::XML xml_data
  end
  
  def expected_file_args
    args = []
    xml.search("arg").each{|arg|
      if arg[:type] == "filepath" and arg[:flag].nil?
        args << arg
      end
    }
    args
  end
  
  def plugin_directory
    dirname = "#{id}_#{self.alias.gsub(' ','_').underscore}"
    PLUGIN_DIRECTORY_PATH.join(dirname)
  end
  
  def path_directory
    return nil unless path
    File.dirname(path)
  end
    
  # private
  
  def create_plugin_directory
    Dir.mkdir plugin_directory
  end
  
  def create_documentation
    tab = "  "
    
    def h1(s); "## #{s.to_s.upcase}\n\n"; end
    
    name = xml.at('command')[:name]
    alias_name = xml.at('command')[:alias]
    version = xml.at('command')[:version]
    title = alias_name + "(1) -- " + name
    
    output_filename = "doc/#{id}_#{alias_name}.ronn"
    file = File.new(output_filename, 'w')
    file.puts title
    file.puts '='*title.length
    file.puts
    
    file.puts h1(:description)
    file.puts tab + xml.at('command')[:description]
    file.puts
    
    file.puts h1 :options
    xml.search('arg').each{|arg|
      file.puts tab + "* `#{arg[:flag]}`, `#{arg[:name]}` <#{arg[:type]}>:"
      file.print tab + arg[:description]
      file.print " [**#{arg[:default]}**]" if arg[:default]
      file.puts
    }
    file.close
    
    `ronn #{output_filename}`
  end
  
  private
  
  def xs(str)
    "xs:#{str}"
  end
  
  def parse_xml_data
    # assign command attributes
    %w(alias description module name version).each{|attribute|
      self.send(attribute + "=", xml.at("command")[attribute])
      # p xml.at("command")[attribute]
    }
    
    # build xsd
    builder = Nokogiri::XML::Builder.new do |doc|
      doc.send('xs:schema', :'xmlns:xs' => "http://www.w3.org/2001/XMLSchema"){
        doc.send('xs:annotation'){
          doc.send('xs:appinfo', xml.at('command')[:name])
          doc.send('xs:documentation', xml.at('command')[:description], 'xml:lang' => 'en')
        }
        doc.send('xs:element', :name => xml.at('command')[:alias]){
          doc.send('xs:complexType'){
            doc.send('xs:choice', :maxOccurs => "unbounded", :minOccurs => "0"){
              xml.search('arg').each{|arg|
                attrs = {}

                restrictions = [:maxExclusive, :maxInclusive, :minExclusive, :minInclusive, :fractionDigits, :length, :maxLength, :minLength, :pattern, :whiteSpace, :totalDigits, :acceptedValues]
                complex_restrictions = !(arg.keys & restrictions.map(&:to_s)).empty?

                [:name, :default].each{|a|
                  attrs[a] = arg[a] if arg[a]
                }

                type = arg[:type]
                type = 'string' if type == "filepath"
                attrs[:type] = xs(type) if type and !complex_restrictions
                attrs[:nillable] = "true"

                doc.send('xs:element', attrs){
                  if complex_restrictions
                    doc.send('xs:simpleType'){
                      doc.send('xs:restriction', :base => 'xs:' + type){
                        restrictions.each{|a|
                          if a == :acceptedValues and arg[:acceptedValues]
                            arg[:acceptedValues].split(',').map(&:strip).each{|value|
                              doc.send('xs:enumeration', :value => value)
                            }
                          else
                            doc.send(xs(a), :value => arg[a]) if arg[a]
                          end
                        }
                      }
                    }
                  end
                }
              }
            }
          }
        }
      }
    end

    self.xsd_data = builder.to_xml


    # default XML preference file
    builder = Nokogiri::XML::Builder.new do |doc|
      doc.send(xml.at('command')[:alias]){
        doc << "\n"
        xml.search('arg').each{|arg|
          # Nokogiri::XML::Comment.new("test", doc)
          doc << "<!-- (#{arg[:type]}) #{arg[:description]}-->\n"
          default = arg[:default] ? arg[:default] : nil
          default = 'false' if default.nil? && arg[:type].index('boolean')
          
          # for integer parameters with no default value
          # default = "" if !arg[:default] and arg[:type] == "integer"
          
          doc.send(arg[:name], default)
          doc << "\n\n"
        }
      }
    end
    self.default_xml_preferences_data = builder.to_xml
    true
    
  end
end
