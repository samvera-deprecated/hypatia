require 'active-fedora'
require File.join(File.dirname(__FILE__), "/../config/environment.rb")
require File.join(File.dirname(__FILE__), "/../app/models/hypatia_xanadu_item")
require File.join(File.dirname(__FILE__), "/../app/models/hypatia_item_desc_metadata_ds")

class FtkItemBuilder
  def initialize()
    ActiveFedora.init
    puts Fedora::Repository.instance.fedora_version
    
    @f = HypatiaXanaduItem.new
    @f.save
    puts "saved as #{@f.pid}"
    desc = @f.datastreams['descMetadata']
    puts desc.class
    desc.content = descMetadata
    desc.ng_xml = Nokogiri::XML::Document.parse(descMetadata)
    desc.dirty = true
    desc.save
    
    content = @f.datastreams['contentMetadata']
    puts content.class
    content.content = contentMetadata
    content.ng_xml = Nokogiri::XML::Document.parse(contentMetadata)
    content.dirty = true
    content.save
    
    # rights = f.datastreams['rightsMetadata']
    # puts rights.class
    # rights.content = rightsMetadata
    # rights.ng_xml = Nokogiri::XML::Document.parse(rightsMetadata)
    # rights.dirty = true
    # rights.save
    
    id = @f.datastreams['identityMetadata']
    puts id.class
    id.content = identityMetadata
    id.ng_xml = Nokogiri::XML::Document.parse(identityMetadata)
    id.dirty = true
    id.save
    
    @f.datastreams["rightsMetadata"].permissions({:group=>"public"}, "read")
    @f.datastreams["rightsMetadata"].permissions({:group=>"public"}, "discover")
    @f.save
    puts "obj saved as #{@f.pid}"
    
  end
  
  def contentMetadata
    "<?xml version='1.0'?>
    <contentMetadata type='born-digital' objectId='foofile.txt_9999'>
      <resource data='metadata' id='analysis-text' type='analysis' objectId='#{@f.pid}'>
        <file size='504 B' format='WordPerfect 5.1' id='foofile.txt'>
          <location type='filesystem'>files/foofile.txt</location>
          <checksum type='md5'>4E1AA0E78D99191F4698EEC437569D23</checksum>
          <checksum type='sha1'>B6373D02F3FD10E7E1AA0E3B3AE3205D6FB2541C</checksum>
        </file>
      </resource>
    </contentMetadata>"
  end
  

  def rightsMetadata
    '<rightsMetadata xmlns="http://hydra-collab.stanford.edu/schemas/rightsMetadata/v1" version="0.1">
      <access type="discover">
        <machine>
          <group>public</group>
        </machine>
      </access>
      <access type="read">
        <machine>
          <group>public</group>
        </machine>
      </access> 
    </rightsMetadata>'
  end

  def descMetadata
    '<?xml version="1.0"?>
    <mods:mods xmlns:mods="http://www.loc.gov/mods/v3">
     <mods:titleInfo>
       <mods:title>A Heartbreaking Work of Staggering Genius</mods:title>
     </mods:titleInfo>
     <mods:typeOfResource>Journal Article</mods:typeOfResource>
     <mods:physicalDescription>
       <mods:form>Punch Cards</mods:form>
     </mods:physicalDescription>
    </mods:mods>'
  end
  
  def identityMetadata
    '<identityMetadata>
      <objectId>druid:tk694zs2244</objectId>
      <objectType>item</objectType>
      <objectLabel>Test Item 1</objectLabel>
      <objectCreator>DOR</objectCreator>
      <agreementId>druid:ww057vk7675</agreementId>
      <tag>Project : Fake</tag>
    </identityMetadata>'
  end
    
end