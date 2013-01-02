## Website ##
class Application < Sinatra::Base
  
  enable :logging, :inline_templates

  configure :test do
    DataMapper.setup(:default, "sqlite://#{Dir.pwd}/features/support/test.db")
  end
 
  configure :development do
    Bundler.require(:development)
    DataMapper.setup(:default, "sqlite://#{Dir.pwd}/development.db")
  end

  configure :production do
    #ENV['DATABASE_URL'] || 
  end

  get "/style.css" do
    content_type 'text/css', :charset => 'utf-8'
    scss :style
  end

  get "/" do
    @title = "therocketforever"
    haml :index
  end
end


## Opperational Objects ##

module Agency
end

module Operations
  # Process tags from markdown for insortion into DataBase. Tags should be assigned if they already exist & created if they do not. This should be done transactionaly as a redis worker task & return true or false on sucess/failure.  
  def tag(target = self)
    puts "Processing tags for #{target}"
    return true
  end 
end

# Article opperational tasks & methods.
module ActsAsArticle
  def article?
    return true
  end
  def image?
    return false
  end
end

# Image opperational tasks & methods.
module ActsAsImage
  def image?
    return true
  end
  def article?
    return false
  end
end

# Agent should be the only non-worker that ever touches the DB. Agent is also responsable for DB maintenience tasks both system defined as well as rake-task based via the 'Agency' module.
class Agent
  include Agency
  def initialize
  end
end

## Database Magic ##

module Taggable
  include DataMapper::Resource
  is :remixable, :suffix => "tag"

  property :id, Serial
  property :name, String

  #has n :tags, :through => Resource 
end

# DObject is a common root object to be inherited from by all objects requireing persistance to the DB. DObject deffines common opperational tasks for the various model objects.
class DObject
  include DataMapper::Resource
  include Operations
  
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :type, Discriminator
  #Section keyword should be implemented as either a Flag[] or Enum[] property with a default value of 'unsorted' or something to indicate its current status. A state machiene may be viable for tracking changes ond attacting hooks.
  property :section, String, :lazy => true
  
  #before a DObject is saved its appropriate module is conditionaly included.
  before :save do
    if self.type == Article
      self.class.send(:include, ActsAsArticle)
    elsif self.type == Image || EmbededImage
      self.class.send(:include, ActsAsImage)
    end
  end
  
end

class Article < DObject
  #include ActsAsArticle
  remix n, :taggables, :for => "Article", :via => :article_tags, :as => "tags"
  
  property :title, String
  property :body, Text

  has n, :embeded_images, :through => Resource

  def images
    self.embeded_images
  end
end

class Image < DObject
  #include ActsAsImage
  remix n, :taggables, :for => "Image", :via => :image_tags, :as => "tags"
  
  property :title, String
  property :caption, Text
  property :data, Text
end

class EmbededImage < Image
  #include ActsAsImage
  remix n, :taggables, :for => "EmbededImage", :via => :emgeded_image_tags, :as => "tags"

  has n, :articles, :through => Resource
end

#class Tag < DObject
#  property :id, Serial
#
#  has n, :taggables, :through => Resource
#end

DataMapper.finalize.auto_migrate!

Binding.pry unless ENV['RACK_ENV'].to_sym == :test
__END__

## Page Layouts ##

@@layout
!!! 5
%head
  %title #{@title}
  %link{:rel => 'stylesheet', :href => '/style.css'}
%body
  = yield

@@_header

@@_navigation

@@index
%p I am Index!!

@@command
% I am @@command!!

@@operations
%p I am @@operations!!

@@science
%p I am @@science!!

@@_articles
%p I am @@_articles!!

@@_article
%p I am @@_article!!

@@_images
%p I am @@_images!!

@@_image
%p I am @@_image!!

@@_tags
%p I am @@_tags!!
