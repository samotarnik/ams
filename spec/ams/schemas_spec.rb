require 'ams/schemas'

describe 'Ams::Schemas::ArtistSchema' do
  let(:schema) { Ams::Schemas::ArtistSchema }

  it 'can be valid' do
    artist_hash = {name: "To Kill a King", am_id: "mn0002677665", url_part: "to-kill-a-king-mn0002677665"}
    expect(schema.call(artist_hash).success?).to be true
  end

  it 'is not valid with incorrect artist id' do
    wrong = {name: 'Radiohead', am_id: 'asdf', url_part: 'radiohead-mn0123456789'}
    expect(schema.call(wrong).messages.keys).to eq [:am_id]

    wrong = {name: 'Radiohead', am_id: 'mn012345678', url_part: 'radiohead-mn0123456789'}
    expect(schema.call(wrong).messages.keys).to eq [:am_id]

    wrong = {name: 'Radiohead', am_id: 'mn01234567890', url_part: 'radiohead-mn0123456789'}
    expect(schema.call(wrong).messages.keys).to eq [:am_id]

    wrong = {name: 'Radiohead', am_id: 'MN0123456789', url_part: 'radiohead-mn0123456789'}
    expect(schema.call(wrong).messages.keys).to eq [:am_id]
  end
end
