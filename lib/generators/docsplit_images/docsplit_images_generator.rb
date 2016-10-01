require 'rails/generators/active_record'

class DocsplitImagesGenerator < ActiveRecord::Generators::Base
  argument :attachment_names, :required => true, :type => :array, :desc => "The names of the attachment(s) to add.",
           :banner => "attachment_one attachment_two attachment_three ..."

  def self.source_root
    @source_root ||= File.expand_path('../templates', __FILE__)
  end

  def generate_migration
    migration_template "docsplit_images_migration.rb.erb", "db/migrate/#{docsplit_images_migration_file_name}"
  end

  protected

  def docsplit_images_migration_name
    "add_docsplit_images_attribute_to_#{name.underscore.pluralize}"
  end

  def docsplit_images_migration_filename
    "#{docsplit_images_migration_name}.rb"
  end

  def migration_class_name
    migration_name.camelize
  end
end
