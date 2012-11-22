module DocsplitImages
  module Conversion
    def self.included(base)
      
      base.before_save :check_for_file_change
      base.after_save :docsplit_images
      
      def check_for_file_change
        @file_has_changed = self.file.dirty?
        true
      end
      
      def docsplit_images
        if self.is_pdf_convertible? and @file_has_changed == true
          self.delay.docsplit_images_process
        end
        true
      end

      def docsplit_images_process
        parent_dir = File.dirname(File.dirname(self.send(@@attachment_name).path))
        FileUtils.rm_rf("#{parent_dir}/images")
        FileUtils.mkdir("#{parent_dir}/images")
        Docsplit.extract_images(self.send(@@attachment_name).path, {:output => "#{parent_dir}/images"})
        self.number_of_images_entry = Dir.entries("#{parent_dir}/images").size - 2
        @file_has_changed = false
        self.save(:validate => false)    
      end

      def is_pdf_convertible?
        extname = File.extname(self.send("#{@@attachment_name}_file_name").downcase.gsub(".", "")
        return ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'odt', 'ods', 'odp'].index( extname ) != nil      
      end

      def document_images_folder
        return "#{File.dirname(File.dirname(self.send(@@attachment_name).url))}/images"
      end

      def document_images_list
        if self.is_pdf_convertible?
          list = []
          image_base_folder = document_images_folder
          original_file_name = File.basename(self.send(@@attachment_name).url, ".*")
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
    def docsplit_images_conversion_for(attribute)
      @@attachment_name = attribute
      self.send(:include, DocsplitImages::Conversion)
    end
  end
end