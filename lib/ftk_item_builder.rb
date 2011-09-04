require 'active-fedora'
require File.join(File.dirname(__FILE__), "/../config/environment.rb")
require File.join(File.dirname(__FILE__), "/../app/models/hypatia_xanadu_item")
require File.join(File.dirname(__FILE__), "/../app/models/hypatia_item_desc_metadata_ds")
# $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "/../../vendor/plugins/hydra-head/lib/hydra"))

class FtkItemBuilder
  def initialize()
    ActiveFedora.init
    puts Fedora::Repository.instance.fedora_version
    
    f = HypatiaXanaduItem.new
    f.save
    puts "saved as #{f.pid}"
    desc = f.datastreams['descMetadata']
    puts desc.class
    desc.content = descMetadata
    desc.ng_xml = Nokogiri::XML::Document.parse(descMetadata)
    desc.dirty = true
    desc.save
    
    content = f.datastreams['contentMetadata']
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
    
    id = f.datastreams['identityMetadata']
    puts id.class
    id.content = identityMetadata
    id.ng_xml = Nokogiri::XML::Document.parse(identityMetadata)
    id.dirty = true
    id.save
    
    f.datastreams["rightsMetadata"].permissions({:group=>"public"}, "read")
    f.datastreams["rightsMetadata"].permissions({:group=>"public"}, "discover")
    f.save
    puts "obj saved as #{f.pid}"
    
  end
  
  def contentMetadata
    '<contentMetadata type="born-digital" objectId="druid:tk694zs2244">
      <resource id="analysis-text" type="analysis" data="metadata" objectId="druid:nd615pr9748">
        <file id="item1.txt" format="TEXT" mimetype="text/plain" encoding="UTF-8" size="1250" preserve="yes" shelve="yes" deliver="yes">
          <location type="url">http://stacks.stanford.edu/file/druid:nd615pr9748/item1.txt</location>
          <checksum type="md5">37cf7f100f80d4088ca011ad977a154b</checksum>
          <checksum type="sha1">a25bc23d85ac1d584bfdce4976149842e8280ad6</checksum>
        </file>
      </resource>
    </contentMetadata>'
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