RSpec.describe NetworkProfile::Extractor do
  specify 'https url' do
    extractor = NetworkProfile::Extractor.new("laba rabaraba https://github.com/zealot128")
    expect(extractor.links).to be == ['https://github.com/zealot128']
  end
  specify 'only www' do
    extractor = NetworkProfile::Extractor.new("laba rabaraba www.github.com/zealot128")
    expect(extractor.links).to be == ['https://www.github.com/zealot128']
  end
  specify 'missing www but url' do
    extractor = NetworkProfile::Extractor.new("laba rabaraba github.com/zealot128")
    expect(extractor.links).to be == ['https://github.com/zealot128']
  end
  specify 'everything kaputt' do
    extractor = NetworkProfile::Extractor.new("laba rabaraba www . github . com / zealot128")
    expect(extractor.links).to be == ['https://www.github.com/zealot128']
  end
end
