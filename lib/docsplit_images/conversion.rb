module DocsplitImages
  module Conversion
    def self.included(base)
      
      base.before_save :check_for_file_change
      base.after_save :docsplit_images
      
      def check_for_file_change
        @file_has_changed = self.send(self.class.docsplit_attachment_name).dirty?
        if @file_has_changed == true
          self.is_processing_image = true
        end
        true
      end
      
      def docsplit_images
        if self.send(self.class.docsplit_attachment_name).exists? and self.is_pdf_convertible? and @file_has_changed == true
          self.delay.docsplit_images_process
        end
        true
      end

      def docsplit_images_process
        parent_dir = File.dirname(File.dirname(self.send(self.class.docsplit_attachment_name).path))
        FileUtils.rm_rf("#{parent_dir}/images")
        FileUtils.mkdir("#{parent_dir}/images")
        doc_path = (self.send(self.class.docsplit_attachment_name).path        
        ext = File.extname(doc_path)
        temp_pdf_path = if ext.downcase == '.pdf'
          doc
        else
          tempdir = File.join(Dir.tmpdir, 'docsplit')
          Docsplit.extract_pdf([doc_path], {:output => tempdir})
          File.join(tempdir, File.basename(doc, ext) + '.pdf')
        end
        self.total_number_of_pages = Docsplit.extract_length(temp_pdf_path)
        self.save(validate: false)
        
        # Going to convert to images
        Docsplit::ImageExtractor.new.extract_images(temp_pdf_path, self.class.docsplit_attachment_options.merge({:output => "#{parent_dir}/images"}))
        @file_has_changed = false
        self.is_processing_image = false
        self.save(:validate => false)    
      end
      
      ## paperclip overriding
      def prepare_for_destroy
        begin
          parent_dir = File.dirname(File.dirname(self.send(self.class.docsplit_attachment_name).path))
          FileUtils.rm_rf("#{parent_dir}/images")
        rescue
        end
        super
      end

      def is_pdf_convertible?
        extname = File.extname(self.send("#{self.class.docsplit_attachment_name}_file_name")).downcase.gsub(".", "")
        return ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'odt', 'ods', 'odp', 'pdf'].index( extname ) != nil      
      end

      def document_images_folder
        return "#{File.dirname(File.dirname(self.send(self.class.docsplit_attachment_name).url))}/images"
      end

      def document_images_list
        if self.is_pdf_convertible?
          list = []
          image_base_folder = document_images_folder
          original_file_name = File.basename(self.send(self.class.docsplit_attachment_name).url, ".*")
          for i in 1..self.number_of_images_entry
            list.push("#{image_base_folder}/#{original_file_name}_#{i}.png")
          end
          return list
        else
          return []
        end
      end      
    end
  end
  
  module ClassMethods
    def docsplit_images_conversion_for(attribute, opts={})
      self.instance_eval do 
        cattr_accessor :docsplit_attachment_name
        cattr_accessor :docsplit_attachment_options
        self.docsplit_attachment_name = attribute
        self.docsplit_attachment_options = opts
      end      
      self.send(:include, DocsplitImages::Conversion)
    end
  end
end