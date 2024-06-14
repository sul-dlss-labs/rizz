# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InfoBuilder do
  let(:info) { described_class.call(filepath: 'images/bc151bq1744_00_0001.jp2', id:) }

  let(:id) { 'https://stacks.stanford.edu/image/iiif/bc151bq1744_00_0001' }

  it 'returns an image information response' do
    expect(info).to match({
                            '@context': 'http://iiif.io/api/image/3/context.json',
                            id:,
                            type: 'ImageService3',
                            protocol: 'http://iiif.io/api/image',
                            profile: Settings.iiif.profile_level,
                            height: 7057,
                            width: 5240,
                            sizes: [{ height: 110, width: 81 }, { height: 220, width: 163 },
                                    { height: 441, width: 327 }, { height: 882, width: 655 },
                                    { height: 1764, width: 1310 }, { height: 3528, width: 2620 },
                                    { height: 7057, width: 5240 }],
                            tiles: { height: 1024, scaleFactors: [1, 2, 4, 8, 16, 32, 64], width: 1024 }

                          })
  end
end
