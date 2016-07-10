require 'logger'

require 'ams/constants'

module Ams
  module Logger
    $ams_logger ||= ::Logger.new("#{Ams::Constants::APP_PATH}/log/data-retrieval.log")

    def log level, msg
      $ams_logger.send level, "#{self.class.name} -- #{am_id}: #{msg}"
    end
  end
end
