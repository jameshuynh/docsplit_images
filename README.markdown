# docsplit_images

[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/jameshuynh/docsplit_images)

Docsplit images is used to convert a document file (pdf, xls, xlsx, ppt, pptx, doc, docx, etc...) to a list of images combining with famous paperclip gem at [https://github.com/thoughtbot/paperclip](paperclip)

## Installation

### Install Docsplit gem dependency (Referring from [http://documentcloud.github.com/docsplit/](http://documentcloud.github.com/docsplit/))
  
#### 1. Install GraphicsMagick. Its ‘gm’ command is used to generate images. Either compile it from source, or use a package manager:

```bash
[aptitude | port | brew] install graphicsmagick
```

#### 2. Install Poppler. On Linux, use aptitude, apt-get or yum:

```bash
aptitude install poppler-utils poppler-data
```

On Mac, you can install from source or use MacPorts:

```bash
sudo port install poppler | brew install poppler
```

#### 3. (Optional) Install Ghostscript:

```bash
[aptitude | port | brew] install ghostscript
```

Ghostscript is required to convert PDF and Postscript files. 

#### 4. (Optional) Install Tesseract:

```bash
[aptitude | port | brew] install [tesseract | tesseract-ocr]
```

Without Tesseract installed, you'll still be able to extract text from documents, but you won't be able to automatically OCR them. 

#### 5. (Optional) Install pdftk. On Linux, use aptitude, apt-get or yum:

```bash
aptitude install pdftk
```
	
On the Mac, you can download a [http://www.pdflabs.com/docs/install-pdftk/](recent installer for the binary). Without pdftk installed, you can use Docsplit, but won't be able to split apart a multi-page PDF into single-page PDFs. 

#### 6. (Optional) Install OpenOffice. On Linux, use aptitude, apt-get or yum:
  
```bash
aptitude install openoffice.org openoffice.org-java-common
```  

On Mac, download and install [http://www.openoffice.org/download/index.html](http://www.openoffice.org/download/index.html).

### Install Gem

	gem 'docsplit_images', :git => 'git@github.com:jameshuynh/docsplit_images.git', tag: "v0.2.1"

## Setting Up
	
From terminal, type the command to install
	
```bash
bundle
rails g docsplit_images <table_name> <attachment_field_name>
# e.g. rails generate docsplit_images asset document
rake db:migrate
```

In your model:

```ruby
class Asset < ActiveRecord::Base
  ...
  attr_accessible :mydocument
  has_attached_file :mydocument
  docsplit_images_conversion_for :mydocument, {size: "800x"}
  ...
end
```

## Processing Images

docsplit_images requires delayed_job to be turned on the process. 

	[bundle exec] rake jobs:work

While it is processing using [https://github.com/collectiveidea/delayed_job](delayed_job), you can check if it is processing by accessing attribute ``is_processing_image``

```ruby
asset.is_processing_image?
```

## Total number of pages

* If your document file is not PDF, this will be non-zero after the internal conversion to PDF has been completed. 

```ruby
asset.number_of_images_entry
```

## Checking the number of images which has been completed

```ruby
asset.number_of_completed_images
```

## Checking the overall conversion progress

```ruby
asset.images_conversion_progress
# => 0.45 (which is 45%)
```

## Accessing list of images using ``document_images_list``

``document_images_list`` will return a list of URL of images converting from the document

```ruby
asset.document_images_list
# => ["/system/myfile_revisions/files/000/000/019/images/SBA_Admin_workflow_1.png", "/system/myfile_revisions/files/000/000/019/images/SBA_Admin_workflow_2.png", ...]
```

Contributing to docsplit_images
-------------
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
-------------

Copyright (c) 2012 jameshuynh. See LICENSE.txt for
further details.