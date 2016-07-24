require 'ams/models/artist'

describe Ams::Models::Artist do

  describe 'attributes:' do
    let(:artist) { described_class.new }

    it 'has a name' do
      artist.name = 'kekec'
      expect(artist.name).to eq 'kekec'
    end

    it 'has an allmusic id' do
      artist.am_id = 'mn09532453'
      expect(artist.am_id).to eq 'mn09532453'
    end

    it 'has a url part that also sets the allmusic id' do
      artist.url_part = 'radiohead-mn95435243'
      expect(artist.url_part).to eq 'radiohead-mn95435243'
      expect(artist.am_id).to eq 'mn95435243'

      artist.url_part = nil
      expect(artist.url_part).to be nil
      expect(artist.am_id).to be nil

      artist.am_id = 43
      expect(artist.url_part).to be nil
      expect(artist.am_id).to eq 43
    end
  end

  describe 'instance methods:' do
    it 'can be converted to a hash' do
      artist = described_class.new
      expect(artist.to_hash).to eq({})

      artist.name = 'kekec'
      expect(artist.to_hash).to eq({name: 'kekec'})

      artist.url_part = 'radiohead-mn95435243'
      expect(artist.to_hash).to eq({name: 'kekec', url_part: 'radiohead-mn95435243', am_id: 'mn95435243'})
    end
  end

  describe 'validations:' do
    it 'can be validated w/ errors' do
      artist = described_class.new
      expect(artist.valid?).to eq false
      expect(artist.errors.keys).to include(:name, :url_part, :am_id)

      artist.name = 'Radiohead'
      expect(artist.valid?).to eq false
      expect(artist.errors.keys).to include(:am_id, :url_part)
      expect(artist.errors.keys).to_not include(:name)

      artist.url_part = 'radiohead-mn0123456789'
      expect(artist.valid?).to eq true
      expect(artist.errors.empty?).to eq true
    end
  end

end
