module DocsplitImages
  class DocsplitImagesJob < Struct.new(:class_name, :id)
    def perform
      object = class_name.constantize.find_by_id(id)
      object.docsplit_images_process
    end
  end
end