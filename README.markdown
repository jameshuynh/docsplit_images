# docsplit_images

Docsplit images is used to convert a document file (pdf, xls, xlsx, ppt, pptx, doc, docx, etc...) to a list of images

## Installation

	gem 'docsplit_images', '0.1.1', :git => 'git@github.com:RubifyTechnology/docsplit_images.git'

## Setting Up
	
From terminal, type the command to install
	
	bundle
	rails g docsplit_images <table_name> <attachment_field_name>
	# e.g rails generate docsplit_images asset document
	rake db:migrate

In your model:

  class Asset < ActiveRecord::Base
    ...
    attr_accessible :document
    has_attached_file :document
    docsplit_images_conversion_for :document
    ...
  end
  
## Accessing list of images using ``document_images_list``

``document_images_list`` will return a list of URL of images converting from the document

  asset.document_images_list
  # => [
    "/system/myfile_revisions/files/000/000/019/images/SBA_Admin_workflow_1.png", 
    "/system/myfile_revisions/files/000/000/019/images/SBA_Admin_workflow_2.png", ...
  ]

Then open your browser at http://localhost:3000 and fill in username: superadmin, password: password to login

* To configure email sender for devise, you can change it in ``config/config.yml`` - ``email_sender`` option
* You can configure application name in ``config/config.yml`` - ``project_name`` option

## Usage