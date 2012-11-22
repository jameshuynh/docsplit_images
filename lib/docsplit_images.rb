require 'rubygems'

module DocsplitImages  
  class Engine < Rails::Engine
    ActiveRecord::Base.send(:include, DocsplitImages::ClassMethods)
  end
end