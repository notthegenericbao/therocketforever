ENV['RACK_ENV'] = 'development'

require 'bundler'

Bundler.require(:default, :development)

require File.join(File.dirname(__FILE__), 'application.rb')

#require_relative 'application'
#require 'pry'

#librarian = Librarian.new

namespace :development do
  task :deploy do
    Rake::Task["development:encode"].invoke
    #Rake::Task["development:article_encode"].invoke
    #Rake::Task["development:image_encode"].invoke
  end
  
  task :encode do
    puts "I am the Encoder!"
    Librarian.encode
  end
  
  task :articles_index do
    puts "I am the Article Indexer"
    Librarian.index
  end
  
  task :images_encode do
    puts "I am the Image encoder"
    librarian.encode
  end
end