require 'rubygems'
require 'docsplit'
require 'docsplit_images/conversion'
require 'docsplit_images/docsplit_images_job'
module DocsplitImages  
  class Engine < Rails::Engine
    ActiveRecord::Base.send(:extend, DocsplitImages::ClassMethods)
  end
end