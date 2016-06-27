require 'sidekiq'
require 'typhoeus'

require_relative './extracts_relationships.rb'

module Ams
  class PullsRelationships
    include Sidekiq::Worker
    sidekiq_options queue: 'pulls_relationships', retry: false

    attr_reader :am_id

    def perform am_id
      @am_id = am_id

      if already_processed?
        log(:info, 'already processed')
        return
      end

      response = Typhoeus.get relationships_url
      if response.success?
        save_file response.body
        ExtractsRelationships.perform_async(am_id)
        log(:info, 'success')
      else
        if response.timed_out?
          msg = 'timed out'
        elsif response.code == 0
          msg = response.return_message
        else
          msg = "failed #{response.code}"
        end
        log(:error, msg)
      end
    end


    private

    def already_processed?
      File.exist?(json_file) || File.exist?(html_file)
    end

    def relationships_url
      "#{BASE_URL}/artist/#{am_id}/related"
    end

    def html_file
      "#{APP_PATH}/data/relationships/html/#{am_id}.html"
    end

    def json_file
      "#{APP_PATH}/data/relationships/json/#{am_id}.json"
    end

    def save_file html
      File.open(html_file, 'w') { |f| f.write(html) }
    end

    def log level, msg
      LOGGER.send level, "#{self.class.name} -- #{am_id}: #{msg}"
    end
  end
end
