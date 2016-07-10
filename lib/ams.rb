$LOAD_PATH.unshift File.absolute_path(File.dirname(__FILE__))

require 'ams/helpers'
require 'ams/workers/extracts_relationships'
require 'ams/workers/pulls_relationships'


# All Music Something, can't think of a better name...
module Ams
  class Init
    include Ams::Helpers

    def initialize am_id=nil
      @am_id = am_id
    end

    def relationships
      Ams::Workers::PullsRelationships.perform_async(@am_id) unless @am_id.nil?
      Dir.glob("#{relationships_html_folder}/*.html") do |file|
        am_id = File.basename(file, '.html')
        puts "queueing #{am_id}"
        Ams::Workers::ExtractsRelationships.perform_async(am_id)
      end
    end
  end
end
