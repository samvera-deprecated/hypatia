# Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file }
# Dir[File.dirname(__FILE__) + '/../app/models/*.rb'].each {|file| require file }
require 'bagit'
require 'ftk_processor'

# Assemble FTK output into objects for Hypatia. 
# @example Process an FTK report and a directory of files
#  my_fedora_config = "/path/to/fedora.yml"
#  my_bag_dir = "/path/to/where/my/bags/should/be/created"
#  ftk_report = "/path/to/FTK_Report.xml"
#  file_dir = "/path/to/exported/ftk/file/directory"
#  hfo = HypatiaFileObjectAssembler.new(:fedora_config => my_fedora_config, :bag_destination => my_bag_dir)
#  hfo.process(ftk_report, file_dir)
class FtkItemAssembler
  
  # The FTK report to process
  attr_accessor :ftk_report
  # The FtkProcessor object used to parse the FTK report
  attr_accessor :ftk_processor
  # Where should I copy the files from?
  attr_accessor :file_dir
  # Where should I copy the display derivative HTML from?
  attr_accessor :display_derivative_dir
  # When I create BagIt packages, where should they go?
  attr_accessor :bag_destination
  # The fedora config we're connecting to, if it has been set explicitly
  attr_accessor :fedora_config
  # The collection these files belong to
  attr_accessor :collection_pid
# TODO:  remove collection_name
   # The name of the collection. Used in generating field values for this item
#  attr_accessor :collection_name
  
  # @param [Hash] args 
  # @param [Hash[:fedora_config]] 
  def initialize(args={})
    @logger = Logger.new('log/ftk_item_assembler.log')
    @logger.debug 'Initializing Hypatia File Object Assembler'
    
    if args[:fedora_config]
      @fedora_config = args[:fedora_config]
      ActiveFedora.init(args[:fedora_config])
    else
      ActiveFedora.init
    end
    
    if args[:collection_pid]
      @collection_pid = args[:collection_pid]
#      get_collection_info
    end
    
    setBagDestination(args)
  end

# TODO:  do we still want this for descMetadata?  
  # Fetch the collection object from solr and get data from it
  # @deprecated ?
=begin 
  def get_collection_info
    solr_params={}
    solr_params[:q]="id:#{@collection_pid.gsub(':','*')}"
    # solr_params[:qt]='document'
    solr_params[:fl]='title_t,id'
    solr_response = Blacklight.solr.find(solr_params)
    
    # Log a message if we can't find any disk images that this file belongs to
    if solr_response.docs.count == 0
      @logger.warn "No collection objects matching #{@collection_pid}."
    else
      document = solr_response.docs.first
      @collection_name = document[:title_t].to_s
    end
  end
=end
  
  # Create an "is_member_of_collection" relationship
  # @param [HypatiaFtkItem]
  def link_to_collection(hypatia_item)
    if @collection_pid
      hypatia_item.add_relationship(:is_member_of_collection,@collection_pid)
    end
  end
  
  # Determine where bags should be written and set the value of @bag_destination
  # @param [Hash] args the args that were passed to initialize this object
  def setBagDestination(args)
    if args[:bag_destination]
      @bag_destination = args[:bag_destination]
    else
      @bag_destination = "/tmp"
    end
  end
  
  # Process an FTK report and turn each of the files into fedora objects
  # @param [String] ftk_report the path to the FTK report
  # @param [String] file_dir the directory holding the files
  def process(ftk_report, file_dir, display_derivative_dir=nil)
    @logger.debug "ftk report = #{ftk_report}"
    @logger.debug "file_dir = #{file_dir}"
    @ftk_report = ftk_report
    
    # Set the value of the FTK file dir
    raise "Directory #{file_dir} not found" unless File.directory? file_dir
    @file_dir = file_dir
    
    # Set the value of the FTK display derivatives dir if it exists
    unless display_derivative_dir.nil?
      raise "Directory #{display_derivative_dir} not found" unless File.directory? display_derivative_dir
      @display_derivative_dir = display_derivative_dir
    end
    
    @ftk_processor = FtkProcessor.new(:ftk_report => @ftk_report, :logfile => @logger)
    @ftk_processor.files.each do |ftk_file|
      create_hypatia_item(ftk_file[1])
    end
  end
  
  # Create a bagit package for an FTK file
  # @param [FtkFile] The FTK file object 
  # @return [BagIt::Bag]
  def create_bag(ff)
    raise "I can't create a bag without knowing where the files come from" unless @file_dir
    @logger.debug "Creating bag for #{ff.unique_combo}"
    bag = BagIt::Bag.new File.join(@bag_destination, "/#{ff.unique_combo}")
    descMeta = buildDescMetadata(ff)
    contentMeta = buildContentMetadata(ff,"n/a","n/a")
    bag.add_file("descMetadata.xml") do |io|
      io.puts descMeta
    end
    bag.add_file("contentMetadata.xml") do |io|
      io.puts contentMeta
    end
    bag.add_file("rightsMetadata.xml") do |io|
      io.puts buildRightsMetadata(ff)
    end
    bag.add_file("RELS-EXT.xml") do |io|
      io.puts buildRelsExt(ff)
    end
    copy_payload(ff,bag)
    bag.manifest!
    @logger.info "Bag created at #{bag.bag_dir}"
    return bag
  end
  
  # Copy the payload file from the source destination to the bagit package
  # @param [FtkFile] ff FTK file object
  # @param [BagIt::Bag] bag The bagit directory destination
  def copy_payload(ff,bag)
    source_file = File.join(@file_dir,ff.export_path)
    @logger.error "Couldn't find file #{source_file} for bagging" unless File.file? source_file
    bag.add_file(ff.filename, source_file)
  end
  
  # Build a MODS record for the FtkFile 
  # @param [FtkFile] ff FTK file object
  # @return [Nokogiri::XML::Document]
  # @example document returned
  #  <?xml version="1.0"?>
  #  <mods:mods xmlns:mods="http://www.loc.gov/mods/v3">
  #   <mods:titleInfo>
  #     <mods:title>A Heartbreaking Work of Staggering Genius</mods:title>
  #   </mods:titleInfo>
  #   <mods:typeOfResource>Journal Article</mods:typeOfResource>
  #   <mods:physicalDescription>
  #     <mods:form>Punch Cards</mods:form>
  #   </mods:physicalDescription>
  #  </mods:mods>
  def buildDescMetadata(ff)
    @logger.debug "building desc metadata for #{ff.unique_combo} "
    builder = Nokogiri::XML::Builder.new do |xml|
      # Really, mods records should be in the mods namespace, 
      # but it makes it a bit of a pain to query them. 
      xml.mods('xmlns:mods' => "http://www.loc.gov/mods/v3") {
        xml.parent.namespace = xml.parent.namespace_definitions.first
        xml['mods'].titleInfo {
          xml['mods'].title_ ff.filename
        }
        
        # If we have a title value, we know this item is part of a larger work
        if ff.title
          xml['mods'].relatedItem('displayLabel' => 'Appears in', 'type' => 'host') {
            xml['mods'].titleInfo {
              xml['mods'].title {
                xml.text ff.title
              }
            }
          }
        end
        
        xml['mods'].location {
#          xml.text "#{@collection_name} - #{ff.disk_image_number} (#{ff.medium})"
          xml.text "#{ff.disk_image_number} (#{ff.medium})"
          xml['mods'].physicalLocation("type"=>"disk"){
            xml.text ff.disk_image_number
          }
          xml['mods'].physicalLocation("type"=>"filepath"){
            xml.text ff.filepath
          }
        }
        xml['mods'].originInfo {
          xml['mods'].dateCreated {
            xml.text ff.file_creation_date
          }
          xml['mods'].dateOther("type" => "last_accessed"){
            xml.text ff.file_accessed_date
          }
          xml['mods'].dateOther("type" => "last_modified"){
            xml.text ff.file_modified_date
          }
        }
        xml['mods'].typeOfResource_ ff.type
        xml['mods'].physicalDescription {
          xml['mods'].form_ ff.medium
        }
      }
    end
    builder.to_xml
  end
  
  # Build a contentMetadata datastream
  # @param [FtkFile] ff FTK file object
  # @param [String] pid The PID of the object this datastream describes
  # @param [String] fileAssetID the PID of the fileAsset containing the content described here
  # @return [Nokogiri::XML::Document]
  # @example document returned
  #  <?xml version="1.0"?>
  #  <contentMetadata type="born-digital" objectId="foofile.txt_9999">
  #    <resource data="metadata" id="analysis-text" type="analysis" objectId="????">
  #      <file size="504 B" format="WordPerfect 5.1" id="foofile.txt">
  #        <location type="filesystem">files/foofile.txt</location>
  #        <checksum type="md5">4E1AA0E78D99191F4698EEC437569D23</checksum>
  #        <checksum type="sha1">B6373D02F3FD10E7E1AA0E3B3AE3205D6FB2541C</checksum>
  #      </file>
  #    </resource>
  #  </contentMetadata>
  # @example calling this method
  #  @ff = FactoryGirl.build(:ftk_file)
  #  @hfo = HypatiaFileObjectAssembler.new(:fedora_config => @fedora_config)
  #  cm = @hfo.buildContentMetadata(@ff)
  #  doc = Nokogiri::XML(cm)
  #  doc.xpath("/contentMetadata/@type").to_s.should eql("born-digital")
  def buildContentMetadata(ff,pid,fileAssetID)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.contentMetadata("type" => "born-digital", "objectId" => pid) {
        xml.resource("id" => "analysis-text", "type" => "analysis", "data" => "metadata", "objectId" => fileAssetID){
          xml.file("id" => ff.filename, "format" => ff.filetype, "size" => ff.filesize) {
            xml.location("type" => "filesystem") {
              xml.text ff.export_path
            }
            xml.checksum("type" => "md5") {
              xml.text ff.md5
            }
            xml.checksum("type" => "sha1") {
              xml.text ff.sha1
            }
          }
        }
      }
    end    
    builder.to_xml
  end
  
  # Build rightsMetadata datastream
  # @param [FtkFile] ff FTK file object
  # @return [Nokogiri::XML::Document]
  def buildRightsMetadata(ff)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.rightsMetadata("xmlns" => "http://hydra-collab.stanford.edu/schemas/rightsMetadata/v1", "version" => "0.1"){
        xml.access("type" => "discover"){
          xml.machine {
            xml.group "public"
          }
        }
        xml.access("type" => "read"){
          xml.machine {
            xml.group "public"
          }
        }
      }
    end
    builder.to_xml
  end
  
  # Build the RELS-EXT datastream
  # @param [FtkFile] ff FTK file object
  # @return [Nokogiri::XML::Document]
  # @example document returned
  #  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:hydra="http://projecthydra.org/ns/relations#" xmlns:rel="info:fedora/fedora-system:def/relations-external#" xmlns:fedora-model="info:fedora/fedora-system:def/model#">
  #    <rdf:Description rdf:about="foofile.txt_9999">
  #      <hydra:isGovernedBy rdf:resource="info:fedora/hypatia:fixture_xanadu_apo"/>
  #      <rel:isMemberOf rdf:resource="PARENT OBJECT GOES HERE"/>
  #      <rel:hasModel rdf:resource="OBJECT MODEL GOES HERE"/>
  #    </rdf:Description>
  #  </rdf:RDF>
  def buildRelsExt(ff)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.RDF("xmlns:rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      "xmlns:fedora-model" => "info:fedora/fedora-system:def/model#", 
      "xmlns:rel"=>"info:fedora/fedora-system:def/relations-external#",
      "xmlns:hydra"=>"http://projecthydra.org/ns/relations#") {
        xml.parent.namespace = xml.parent.namespace_definitions.first
        xml['rdf'].Description("rdf:about" => ff.unique_combo) {
          xml['hydra'].isGovernedBy("rdf:resource" => "info:fedora/hypatia:fixture_xanadu_apo")
          xml['rel'].isMemberOf("rdf:resource" => "PARENT OBJECT GOES HERE")
          xml['rel'].hasModel("rdf:resource" => "OBJECT MODEL GOES HERE")
        }
      }
    end
    builder.to_xml
  end
  
  # Create a hypatia item level fedora object for an FTK file
  # @param [FtkFile] The FTK file object 
  # @return [ActiveFedora::Base]
  def create_hypatia_item(ff)    
    # Don't create objects for files that don't really exist
    # filepath = "#{@file_dir}/#{ff.export_path}"
    # return unless File.file? filepath
    
    hypatia_item = HypatiaFtkItem.new
    hypatia_item.label=ff.filename
    hypatia_item.save
    raise "Couldn't save new hypatia item" unless !hypatia_item.pid.nil?
    
    link_to_disk(hypatia_item,ff)
    link_to_collection(hypatia_item)
    fileAsset = create_hypatia_file(hypatia_item,ff)
    
    build_ng_xml_datastream(hypatia_item, "descMetadata", buildDescMetadata(ff))
    build_ng_xml_datastream(hypatia_item, "contentMetadata", buildContentMetadata(ff,hypatia_item.pid,fileAsset.pid))
    build_ng_xml_datastream(hypatia_item, "rightsMetadata", buildRightsMetadata(ff))
    
    hypatia_item.save
    return hypatia_item
  end
  
  # Find the object for the disk image that this file came from. 
  # Create a relationship between this object and that one.
  # @param [HypatiaFtkItem] hypatia_item
  # @return [Boolean] true for success, false for failure
  def link_to_disk(hypatia_item,ff)
    solr_params={}
    solr_params[:q]="file_id_t:#{ff.disk_image_number}"
    solr_params[:qt]='standard'
    solr_params[:fl]='id'
    solr_response = Blacklight.solr.find(solr_params)
    
    # Log a message if we can't find any disk images that this file belongs to
    if solr_response.docs.count == 0
      raise "No disk image objects matching #{ff.disk_image_number}. #{hypatia_item.pid} has not been correctly populated"
    elsif solr_response.docs.count > 1
      raise "Too many disk image objects matching #{ff.disk_image_number}. #{hypatia_item.pid} has not been correctly populated"
    else
      document = solr_response.docs.first      
      foo = HypatiaDiskImageItem.load_instance(document[:id])
      hypatia_item.add_relationship(:is_member_of,foo)
      hypatia_item.save
      @logger.debug "HypatiaFtkItem #{hypatia_item.pid} is now a member of HypatiaDiskImageItem #{foo.pid}"
    end
    return true
  end
  
  # Create a Nokogiri XML Datastream on the hypatia_item object
  # @param [HypatiaFtkItem] the HypatiaFtkItem object getting the datastream
  # @param [String] the name of the datastream (must correspond to ActiveFedora model name for datastream)
  # @param [String] string to be parsed as a Nokogiri XML Document
  def build_ng_xml_datastream(hypatia_item, dsname, xml)
    ds = hypatia_item.datastreams[dsname]
    ds.content = xml
    ds.ng_xml = Nokogiri::XML::Document.parse(xml)
    ds.dirty = true
    ds.save
  end

  # Create a hypatia file level fedora object for an FTK file
  # @param [HypatiaFtkItem] the FileAsset objects created will have _is_part_of relationships to the object in this param
  # @param [FtkFile] object populated from the FTK report
  # @return [FileAsset] the FileAsset object that is_part_of the ftk item object
  def create_file_asset(hypatia_ftk_item, ftk_file_object)
    file_asset = FileAsset.new
    # the label value ends up in DC dc:title and descMetadata  title ??
    file_asset.label="FileAsset for FTK file #{ftk_file_object.filename}"
    file_asset.add_relationship(:is_part_of, hypatia_ftk_item)
    
    filepath = "#{@file_dir}/#{ftk_file_object.export_path}"
    file = File.new(filepath)
    if (ftk_file_object.mimetype)
      file_asset.add_file_datastream(file, {:dsid => "content", :label => ftk_file_object.filename, :mimeType => ftk_file_object.mimetype})
    else
      file_asset.add_file_datastream(file, {:dsid => "content", :label => ftk_file_object.filename})
    end

    if @display_derivative_dir 
      html_filepath = "#{@display_derivative_dir}/#{ftk_file_object.display_deriv_fname}"
      if File.file?(html_filepath)
        html_file = File.new(html_filepath)
        # NOTE:  if mime_type is not set explicitly, Fedora does it ... but it's not testable
        derivative_ds =  ActiveFedora::Datastream.new(:dsID => "derivative_html", :dsLabel => ftk_file_object.display_deriv_fname, :mime_type => "text/html", :blob => html_file, :controlGroup => 'M')
        file_asset.add_datastream(derivative_ds)
#      else
#        @logger.warn "Couldn't find expected display derivative file #{html_filepath}"
      end
    end
    file_asset.save
    return file_asset
  end

# TODO:  remove this when other is working  
  # Create a hypatia file level fedora object for an FTK file
  # @param [HypatiaItem] hypatia_item
  # @param [FtkFile] ff
  # @return [FileAsset]
  # @deprecated
  def create_hypatia_file(hypatia_item,ff)
    hypatia_file = FileAsset.new
    hypatia_file.label="FileAsset for #{ff.filename}"
    hypatia_file.add_relationship(:is_part_of,hypatia_item)
    filepath = "#{@file_dir}/#{ff.export_path}"
    file = File.new(filepath)
    hypatia_file.add_file_datastream(file, {:dsid => "content", :label => ff.filename})
    
    if @display_derivative_dir 
      html_filepath = "#{@display_derivative_dir}/#{ff.display_derivative}"
      if File.file? html_filepath
        html_file = File.new(html_filepath)
        derivative_ds =  ActiveFedora::Datastream.new(:dsID => "derivative_html", :dsLabel => "Display derivative for #{ff.filename}", :controlGroup => 'M', :blob => html_file)
        hypatia_file.add_datastream(derivative_ds)
      else
        @logger.warn "Couldn't find expected display derivative file #{html_filepath}"
      end
    end
    hypatia_file.save
    return hypatia_file
  end
end