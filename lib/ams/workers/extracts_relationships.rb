require 'json'
require 'oga'
require 'sidekiq'

require 'ams/helpers'
require 'ams/logger'
require 'ams/models/artist'
require 'ams/workers/pulls_relationships'


module Ams
  module Workers
    class ExtractsRelationships
      include Sidekiq::Worker
      include Ams::Helpers
      include Ams::Logger

      sidekiq_options queue: 'extracts_relationships', retry: false
      attr_reader :am_id

      def perform am_id
        @am_id = am_id

        if entry_exists?
          log(:error, 'duplicate entry found')
          return
        end

        if no_data_found?
          log(:error, 'no data file!!!')
          return
        end

        begin
          html = File.read html_file
          relationships = parse_and_extract html
          save_json relationships.to_json
          File.delete html_file
          enqueue_puller relationships
          log(:info, 'success')
        rescue => e
          log(:error, e.message)
        end
      end


      private

      def entry_exists?
        File.exist?(json_file)
      end

      def no_data_found?
        !File.exist?(html_file)
      end

      def html_file
        "#{relationships_html_folder}/#{am_id}.html"
      end

      def json_file
        "#{relationships_json_folder}/#{am_id}.json"
      end

      def save_json json_string
        File.open(json_file, 'w') { |f| f.write(json_string) }
      end

      def parse_and_extract html
        doc = Oga.parse_html html

        result = {}

        artist = Ams::Models::Artist.new
        artist.name = doc.at_css('h1.artist-name').text.strip
        artist.url_part = doc.at_css('.content ul.tabs.related li.tab.related a')
          .attr('href').value.strip.sub(/\/related\z/,'').split('/').last

        if artist.valid?
          result[:artist] = artist.to_hash
        else
          raise StandardError, artist.errors.to_s
        end

        %i(similars influencers followers associatedwith).each do |section|
          result[section] = []
          doc.css("section.related.#{section} li a").each do |link|
            artist = Ams::Models::Artist.new
            artist.name = link.text.strip
            artist.url_part = link.attr('href').value.strip.split('/').last

            if artist.valid?
              result[section] << artist.to_hash
            else
              raise StandardError, artist.errors.to_s
            end
          end
        end

        result
      end

      def enqueue_puller relationships
        %i(similars influencers followers associatedwith).each do |section|
          relationships[section].each do |artist|
            Ams::Workers::PullsRelationships.perform_async artist[:am_id]
          end
        end
      end

    end
  end
end
