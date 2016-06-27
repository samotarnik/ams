
require 'logger'
require_relative './workers/extracts_relationships.rb'
require_relative './workers/pulls_relationships.rb'


# All Music Something, can't think of a better name...
module Ams
  APP_PATH = Dir.pwd
  BASE_URL = 'http://www.allmusic.com'
  LOGGER = Logger.new("#{APP_PATH}/log/data-retrieval.log")

  def self.start am_id=nil
    PullsRelationships.perform_async(am_id) unless am_id.nil?
    Dir.glob("#{APP_PATH}/data/relationships/html/*.html") do |file|
      am_id = File.basename(file, '.html')
      puts "queueing #{am_id}"
      ExtractsRelationships.perform_async(am_id)
    end

  end
end
