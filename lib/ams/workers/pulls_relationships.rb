require 'sidekiq'
require 'typhoeus'

require 'ams/constants'
require 'ams/helpers'
require 'ams/logger'
require 'ams/workers/extracts_relationships'


module Ams
  module Workers
    class PullsRelationships
      include Sidekiq::Worker
      include Ams::Helpers
      include Ams::Logger

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
          Ams::Workers::ExtractsRelationships.perform_async(am_id)
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
        "#{Ams::Constants::BASE_URL}/artist/#{am_id}/related"
      end

      def html_file
        "#{relationships_html_folder}/#{am_id}.html"
      end

      def json_file
        "#{relationships_json_folder}/#{am_id}.json"
      end

      def save_file html
        File.open(html_file, 'w') { |f| f.write(html) }
      end

    end
  end
end
