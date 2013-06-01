require 'rubygems'
require 'docsplit'
require 'docsplit_images/conversion'
module DocsplitImages  
  class Engine < Rails::Engine
    ActiveRecord::Base.send(:extend, DocsplitImages::ClassMethods)
  end
end