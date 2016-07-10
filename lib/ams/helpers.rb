require 'ams/constants'

module Ams
  module Helpers
    def relationships_html_folder
      "#{Ams::Constants::APP_PATH}/data/relationships/html"
    end

    def relationships_json_folder
      "#{Ams::Constants::APP_PATH}/data/relationships/json"
    end
  end
end
