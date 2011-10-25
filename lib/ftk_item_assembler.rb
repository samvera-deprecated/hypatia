require "digest/md5"
require "digest/sha1"
#require 'bagit'

# NAOMI:  revise these comments
# Assemble FTK output into objects for Hypatia. 
# @example Process an FTK report and a directory of files
#  ftk_report = "/path/to/FTK_Report.xml"
#  file_dir = "/path/to/exported/ftk/file/directory"
#  hfo = HypatiaFileObjectAssembler.new(:fedora_config => my_fedora_config, :bag_destination => my_bag_dir)
#  hfo.process(ftk_report, file_dir)
class FtkItemAssembler

# FIXME:  which of these attributes aren't really attributes b/c they are redundant with method params?
#   which of these should be passed in as an arg at .new?
  
  # The FTK report to process
  attr_accessor :ftk_report
  # Where should I copy the files from?
  attr_accessor :file_dir
  # Where should I copy the display derivative HTML from?
  attr_accessor :display_derivative_dir
  # The collection these files belong to
  attr_accessor :collection_pid

# NAOMI:  fix this comment  
# NAOMI:  change the args to just be a collection_pid instead of a hash 
#  OR take the other attributes here ...
  # @param [Hash] args 
  # @param [Hash[:collection_pid]] 
  def initialize(args={})
    @logger = Logger.new('log/ftk_item_assembler.log')
    @logger.debug 'Initializing Hypatia File Object Assembler'

    if args[:collection_pid]
      @collection_pid = args[:collection_pid]
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
    
    # rights metadata is the same for all the files at this time
    @rights_metadata = build_rights_metadata
    
    ftk_processor = FtkProcessor.new(:ftk_report => @ftk_report, :logfile => @logger)
    ftk_processor.files.each do |ftk_file|
      create_hypatia_ftk_item(ftk_file)
    end
  end
  
  # Create a HypatiaFtkItem object for an FtkFile object
  # @param [FtkFile] the intermediate object for the FTK File
  # @return [HypatiaFtkItem] the populated HypatiaFtkItem object, which 
  #   has been saved to Fedora/Solr
  def create_hypatia_ftk_item(ff_intermed)    
    # Don't create objects for files that don't really exist
    # filepath = "#{@file_dir}/#{ff_intermed.export_path}"
    # return unless File.file? filepath
    
    hypatia_item = HypatiaFtkItem.new
    hypatia_item.label = ff_intermed.filename
    hypatia_item.save
    raise "Couldn't save new hypatia item" unless !hypatia_item.pid.nil?
    
    link_to_parent(hypatia_item, ff_intermed)
    build_ng_xml_datastream(hypatia_item, "descMetadata", build_desc_metadata(ff_intermed))
    build_ng_xml_datastream(hypatia_item, "rightsMetadata", @rights_metadata)
    fileAsset = create_file_asset(hypatia_item, ff_intermed)
    build_ng_xml_datastream(hypatia_item, "contentMetadata", build_content_metadata(ff_intermed, hypatia_item.pid, fileAsset))

    hypatia_item.save
    return hypatia_item
  end

  # Build a MODS record for the descMetadata datastream of the HypatiaFtkItem fedora object
  # @param [FtkFile] the intermediate object for the FTK File that is being turned into a Fedora object
  # @return [Nokogiri::XML::Document] - the xmlContent for the descMetadata datastream (a MODS document)
  def build_desc_metadata(ff_intermed)
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

  # Build rightsMetadata datastream for HypatiaFtkItem;  discover and read permissions allowed for all, edit permissions for archivist group
  # @return [Nokogiri::XML::Document] - the xmlContent for the rightsMetadata datastream
  def build_rights_metadata
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.rightsMetadata("xmlns" => "http://hydra-collab.stanford.edu/schemas/rightsMetadata/v1", "version" => "0.1"){
        xml.access("type" => "discover") {
          xml.machine {
            xml.group "public"
          }
        }
        xml.access("type" => "read") {
          xml.machine {
            xml.group "public"
          }
        }
        xml.access("type" => "edit") {
          xml.machine {
            xml.group "archivist"
          }
        }
      }
    end
    builder.to_xml
  end
  
  # Find the object for the disk image that this file came from. 
  # Create a relationship between the ftk file item object and the disk image object.
  #  if there is no match, link to the collection object
  #   Side Effect:  alters passed HypatiaFtkItem (if it finds the correct disk image object)
  # @param [HypatiaFtkItem] the object for the file
  # @param [FtkFile] the intermediate object for the FTK File that is being turned into a Fedora object
  def link_to_parent(hypatia_ftk_item, ff_intermed)
    solr_params = {}
    # sneaky way of finding the disk image title as a string for an exact match
    solr_params[:q] = "title_sort:#{ff_intermed.disk_image_name}"
    solr_params[:qt] = 'standard'
    solr_params[:fl] = 'id'
    solr_response = Blacklight.solr.find(solr_params)
    solr_docs = solr_response.docs
    
    if solr_docs.count == 0
      @logger.warn "No disk image objects match #{ff_intermed.disk_image_name}. #{hypatia_ftk_item.pid} may not have been correctly populated"
    elsif solr_docs.count == 1   # single match -- Yay!
      hdii = HypatiaDiskImageItem.load_instance(solr_docs.first[:id])
      hypatia_ftk_item.add_relationship(:is_member_of, hdii)
      hypatia_ftk_item.save
      @logger.debug "HypatiaFtkItem #{hypatia_ftk_item.pid} is now a member of HypatiaDiskImageItem #{hdii.pid}"
    else    #  solr_docs.count > 1, disambiguate on coll pid
      @logger.warn "More than one disk image object matches #{ff_intermed.disk_image_name}. #{hypatia_ftk_item.pid} may not have been correctly populated"
      matching_hdii_objects = []
      solr_docs.each { | sd | 
        matching_hdii_objects.push(HypatiaDiskImageItem.load_instance(sd[:id]))
      }
      matching_hdii_objects.each { |hdii|  
        if hdii.relationships[:self][:is_member_of_collection].include?("info:fedora/#{@collection_pid}")
          hypatia_ftk_item.add_relationship(:is_member_of, hdii)
          hypatia_ftk_item.save
          @logger.debug "HypatiaFtkItem #{hypatia_ftk_item.pid} is now a member of HypatiaDiskImageItem #{hdii.pid}"
          break
        end
      }
    end
    
    if hypatia_ftk_item.sets.size == 0
      coll_obj = HypatiaCollection.load_instance(@collection_pid)
      hypatia_ftk_item.add_relationship(:is_member_of_collection, coll_obj)
      hypatia_ftk_item.save
      @logger.debug "HypatiaFtkItem #{hypatia_ftk_item.pid} is now a member of HypatiaCollection #{@collection_pid}"
    end
  end # end link_to_parent
  
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
  # @param [FtkFile] the intermediate object for the FTK File that is being turned into a Fedora object
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