require 'securerandom'

module DocsplitImages
  module Conversion
    def self.included(base)
      base.before_save :check_for_file_change
      base.after_commit :docsplit_images
    end

    def check_for_file_change
      @file_has_changed = send(self.class.docsplit_attachment_name).dirty?
      self.is_processing_image = true if @file_has_changed == true
      true
    end

    def docsplit_images
      if send(self.class.docsplit_attachment_name).exists? &&
          pdf_convertible? &&
          @file_has_changed == true
        DocsplitImages::DocsplitImagesJob.perform_async(self.class.name, id)
      end
      true
    end

    def docsplit_images_process
      parent_dir = File.dirname(File.dirname(self.send(self.class.docsplit_attachment_name).path))
      FileUtils.rm_rf("#{parent_dir}/images")
      FileUtils.mkdir("#{parent_dir}/images")
      doc_path = self.send(self.class.docsplit_attachment_name).path
      ext = File.extname(doc_path)
      temp_pdf_path = if ext.downcase == '.pdf'
        doc_path
      else
        uuid = SecureRandom.uuid # Generate a random directory to avoid race-conditions
        tempdir = File.join(Dir.tmpdir, "docsplit/#{uuid}")
        Docsplit.extract_pdf([doc_path], {:output => tempdir})
        File.join(tempdir, File.basename(doc_path, ext) + '.pdf')
      end
      self.number_of_images_entry = Docsplit.extract_length(temp_pdf_path)
      self.save(validate: false)

      # Going to convert to images
      Docsplit::ImageExtractor.new.extract(temp_pdf_path, self.class.docsplit_attachment_options.merge({:output => "#{parent_dir}/images"}))
       @file_has_changed = false
      self.is_processing_image = false
      self.save(:validate => false)

      after_docspliting
    end

    def after_docspliting
      # TO BE IMPLEMENTED BY INCLUDER
    end

    def number_of_completed_images
      parent_dir = \
        File.dirname(
          File.dirname(
            send(self.class.docsplit_attachment_name).path
          )
        )

      Dir.entries("#{parent_dir}/images").size - 2
    end

    # return the progress in term of percentage
    def images_conversion_progress
      if pdf_convertible?
        return sprintf(
          "%.2f",
          number_of_completed_images * 1.0 / number_of_images_entry
        ).to_f
      end
      1
    end

    ## paperclip overriding
    def prepare_for_destroy
      begin
        FileUtils.rm_rf(document_images_path)
      rescue e
        print(e)
      end
      super
    end

    def pdf_convertible?
      extname = File.extname(
        send("#{self.class.docsplit_attachment_name}_file_name")
      ).downcase.delete('.')

      !%w(doc docx xls xlsx ppt pptx odt ods odp pdf).index(extname).nil?
    end

    def document_images_path
      parent_dir = File.dirname(
        File.dirname(
          send(self.class.docsplit_attachment_name).path
        )
      )
      "#{parent_dir}/images"
    end

    def document_images_folder
      "#{File.dirname(
        File.dirname(
          send(self.class.docsplit_attachment_name).url
        )
      )}/images"
    end

    def document_images_list
      return [] unless pdf_convertible?

      list = []
      image_base_folder = document_images_folder
      original_file_name =
        File.basename(send(self.class.docsplit_attachment_name).url, ".*")
      (1..number_of_images_entry).each do |i|
        list.push("#{image_base_folder}/#{original_file_name}_#{i}.png")
      end
      list
    end
  end

  module ClassMethods
    def docsplit_images_conversion_for(attribute, opts = {})
      instance_eval do
        cattr_accessor :docsplit_attachment_name
        cattr_accessor :docsplit_attachment_options
        self.docsplit_attachment_name = attribute
        self.docsplit_attachment_options = opts
      end
      send(:include, DocsplitImages::Conversion)
    end
  end
end
