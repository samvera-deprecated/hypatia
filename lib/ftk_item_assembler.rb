require "digest/md5"
require "digest/sha1"
# Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file }
# Dir[File.dirname(__FILE__) + '/../app/models/*.rb'].each {|file| require file }
#require 'bagit'
#require 'ftk_processor'

# NAOMI:  revise these comments
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
#  attr_accessor :fedora_config
  # The collection these files belong to
  attr_accessor :collection_pid
  
  # @param [Hash] args 
  # @param [Hash[:fedora_config]] 
  def initialize(args={})
    @logger = Logger.new('log/ftk_item_assembler.log')
    @logger.debug 'Initializing Hypatia File Object Assembler'

=begin    # from before this was run within the rails environment
    if args[:fedora_config]
      @fedora_config = args[:fedora_config]
      ActiveFedora.init(args[:fedora_config])
    else
      ActiveFedora.init
    end
=end

    if args[:collection_pid]
      @collection_pid = args[:collection_pid]
    end
    
    set_bag_destination(args)
  end

  # Create an "is_member_of_collection" relationship
  # @param [HypatiaFtkItem]
  def link_to_collection(hypatia_item)
    if @collection_pid
      hypatia_item.add_relationship(:is_member_of_collection,@collection_pid)
    end
  end
  
  # Determine where bags should be written and set the value of @bag_destination
  # @param [Hash] args the args that were passed to initialize this object
  def set_bag_destination(args)
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
      create_hypatia_ftk_item(ftk_file[1])
    end
  end
  
  # Create a hypatia item level fedora object for an FTK file
  # @param [FtkFile] The FTK file object 
  # @return [ActiveFedora::Base]
  def create_hypatia_ftk_item(ff)    
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
    
    build_ng_xml_datastream(hypatia_item, "descMetadata", build_desc_metadata(ff))
    build_ng_xml_datastream(hypatia_item, "contentMetadata", build_content_metadata(ff,hypatia_item.pid,fileAsset.pid))
    build_ng_xml_datastream(hypatia_item, "rightsMetadata", build_rights_metadata(ff))
    
    hypatia_item.save
    return hypatia_item
  end
  
  # Create a bagit package for an FTK file
  # @param [FtkFile] The FTK file object 
  # @return [BagIt::Bag]
  def create_bag(ff)
    raise "I can't create a bag without knowing where the files come from" unless @file_dir
    @logger.debug "Creating bag for #{ff.unique_combo}"
    bag = BagIt::Bag.new File.join(@bag_destination, "/#{ff.unique_combo}")
    descMeta = build_desc_metadata(ff)
    contentMeta = build_content_metadata(ff,"n/a","n/a")
    bag.add_file("descMetadata.xml") do |io|
      io.puts descMeta
    end
    bag.add_file("contentMetadata.xml") do |io|
      io.puts contentMeta
    end
    bag.add_file("rightsMetadata.xml") do |io|
      io.puts build_rights_metadata(ff)
    end
    bag.add_file("RELS-EXT.xml") do |io|
      io.puts build_rels_ext(ff)
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
  
  # Build a MODS record for the descMetadata datastream of the HypatiaFtkItem fedora object
  # @param [FtkFile] the intermediate object for the FTK File that is being turned into a Fedora object
  # @return [Nokogiri::XML::Document] - the xmlContent for the descMetadata datastream (a MODS document)
  def build_desc_metadata(ff_intermed)
    @logger.debug "building desc metadata for #{ff_intermed.unique_combo} "
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.mods('xmlns:mods' => "http://www.loc.gov/mods/v3") {
        xml.parent.namespace = xml.parent.namespace_definitions.first
        xml['mods'].identifier("type"=>"filename") {
          xml.text ff_intermed.filename
        }
        xml['mods'].identifier("type"=>"ftk_id") {
          xml.text ff_intermed.id
        }
        xml['mods'].location {
          xml['mods'].physicalLocation("type"=>"filepath"){
            xml.text ff_intermed.filepath
          }
        }
        xml['mods'].physicalDescription {
          xml['mods'].extent ff_intermed.filesize
          xml['mods'].extent ff_intermed.medium
          xml['mods'].digitalOrigin "born digital"
        }
        xml['mods'].originInfo {
          xml['mods'].dateCreated {
            xml.text ff_intermed.file_creation_date
          }
          xml['mods'].dateOther("type" => "last_accessed"){
            xml.text ff_intermed.file_accessed_date
          }
          xml['mods'].dateOther("type" => "last_modified"){
            xml.text ff_intermed.file_modified_date
          }
        }
        # If we have a title value, we know this item is part of a larger work
        if ff_intermed.title
          xml['mods'].relatedItem('displayLabel' => 'Appears in', 'type' => 'host') {
            xml['mods'].titleInfo {
              xml['mods'].title {
                xml.text ff_intermed.title
              }
            }
          }
        end
        xml['mods'].note("displayLabel" => "filetype") {
          xml.text ff_intermed.filetype
        }
        xml['mods'].note {
          xml.text ff_intermed.type
        }
      }
    end
    builder.to_xml
  end
  
  # Build the contentMetadata for HypatiaFtkItem as an xml object.  it should adhere to the 
  #  xml expected by model HypatiaFtkItemContentMetadataDS
  # @param [FtkFile] the intermediate object for the FTK File that is being turned into a Fedora object
  # @param [String] the Fedora pid of the HypatiaFtkItem object
  # @param [ActiveFedora::FileAsset] the FileAsset object for the ftk file itself, and the display derivative file, if there is one
  # @return [Nokogiri::XML::Document] - the xmlContent for the contentMetadata datastream
  def build_content_metadata(ftk_file_intermed, ftk_item_pid, file_asset)
    content_ds = file_asset.datastreams["content"]
    deriv_ds = file_asset.datastreams["derivative_html"]
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.contentMetadata("type" => "file", "objectId" => ftk_item_pid) {
        xml.resource("id" => content_ds.label, "type" => "file", "objectId" => file_asset.pid) {
          # TODO:  there should be a format attribute with value per the mime_type / extension -> controlled vocab at 
          #   https://consul.stanford.edu/display/chimera/DOR+file+types+and+attribute+values
          content_file_attr = {"id" => content_ds.label, "size" => File.size(content_ds.blob), 
                    "preserve" => "yes", "publish" => "yes", "shelve" => "yes"}
          if (content_ds.mime_type)
            content_file_attr["mimetype"]= content_ds.mime_type
          end
          xml.file(content_file_attr) {
            xml.location("type" => "datastreamID") {
              xml.text "content"
            }
            xml.checksum("type" => "md5") {
              xml.text ftk_file_intermed.md5
            }
            xml.checksum("type" => "sha1") {
              xml.text ftk_file_intermed.sha1
            }
          }
          if deriv_ds
            xml.file("id" => deriv_ds.label, "mimetype" => deriv_ds.mime_type, "format" => "HTML",
                      "size" => File.size(deriv_ds.blob), "preserve" => "yes", "publish" => "yes", "shelve" => "yes" ) {
              xml.location("type" => "datastreamID") {
                xml.text "derivative_html"
              }
              xml.checksum("type" => "md5") {
                  xml.text Digest::MD5.hexdigest(deriv_ds.blob.read)
              }
              xml.checksum("type" => "sha1") {
                xml.text Digest::SHA1.hexdigest(deriv_ds.blob.read)
              }
            }
          end
        }
      }
    end
    builder.to_xml
  end
  
  # Build rightsMetadata datastream
  # @param [FtkFile] ff FTK file object
  # @return [Nokogiri::XML::Document]
  def build_rights_metadata(ff)
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
  def build_rels_ext(ff)
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
  # @param [HypatiaFtkItem] this is the object of an _is_part_of relationship from the FileAsset we are creating
  # @param [FtkFile] object populated from the FTK report
  # @return [FileAsset] the FileAsset object that is_part_of the HypatiaFtkItem object
  def create_file_asset(hypatia_ftk_item, ftk_file_intermed)
    file_asset = FileAsset.new
    # the label value ends up in DC dc:title and descMetadata  title ??
    file_asset.label="FileAsset for FTK file #{ftk_file_intermed.filename}"
    file_asset.add_relationship(:is_part_of, hypatia_ftk_item)
    
    filepath = "#{@file_dir}/#{ftk_file_intermed.export_path}"
    file = File.new(filepath)
    if (ftk_file_intermed.mimetype)
      file_asset.add_file_datastream(file, {:dsid => "content", :label => ftk_file_intermed.filename, :mimeType => ftk_file_intermed.mimetype})
    else
      file_asset.add_file_datastream(file, {:dsid => "content", :label => ftk_file_intermed.filename})
    end

# FIXME:  (sha1 and) md5 are avail from FtkFile object

    if @display_derivative_dir 
      html_filepath = "#{@display_derivative_dir}/#{ftk_file_intermed.display_deriv_fname}"
      if File.file?(html_filepath)
        html_file = File.new(html_filepath)
        # NOTE:  if mime_type is not set explicitly, Fedora does it ... but it's not testable
        derivative_ds =  ActiveFedora::Datastream.new(:dsID => "derivative_html", :dsLabel => ftk_file_intermed.display_deriv_fname, :mimeType => "text/html", :blob => html_file, :controlGroup => 'M')
        file_asset.add_datastream(derivative_ds)
#      else
#        @logger.warn "Couldn't find expected display derivative file #{html_filepath}"
      end
    end
    file_asset.save
    return file_asset
  end

end