require 'dry-validation'

module Ams
  module Schemas
    AM_ID_REGEX = /mn\d{10}/

    ArtistSchema = Dry::Validation.Schema do
      required(:name).filled(:str?)
      required(:am_id).filled(:str?, format?: /\A#{AM_ID_REGEX}\z/)
      required(:url_part).filled(:str?, format?: /\A[\w-]+-#{AM_ID_REGEX}\z/)
    end
  end
end

